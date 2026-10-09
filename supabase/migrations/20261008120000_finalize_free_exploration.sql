-- Keep the latest simplified publication rules after gameplay prerequisites were removed.

-- Nới điều kiện xuất bản cho phạm vi MVP: giảm số mục tối thiểu,
-- tăng trần số từ và linh hoạt hơn với cấu trúc đáp án quiz.

create or replace function public.validate_location_revision(revision_id uuid)
returns text[]
language plpgsql
security definer
set search_path = ''
as $$
declare
  revision public.location_revisions%rowtype;
  errors text[] := '{}';
  quiz_count integer;
begin
  perform private.assert_admin();

  select * into revision
  from public.location_revisions
  where id = revision_id;

  if not found then
    return array['Không tìm thấy Phiên bản nội dung.'];
  end if;

  if revision.status <> 'draft' then
    errors := array_append(errors, 'Chỉ Bản nháp mới có thể Xuất bản.');
  end if;

  if private.is_blank(revision.name)
    or private.is_blank(revision.korean_name)
    or private.is_blank(revision.english_name)
    or private.is_blank(revision.address)
    or private.is_blank(revision.city)
    or private.is_blank(revision.region)
    or private.is_blank(revision.country)
    or private.is_blank(revision.location_type) then
    errors := array_append(
      errors,
      'Tổng quan còn thiếu tên, tên Hàn/Anh, địa chỉ, vùng, quốc gia hoặc loại Địa điểm.'
    );
  end if;

  if revision.latitude is null or revision.longitude is null then
    errors := array_append(errors, 'Tọa độ latitude và longitude là bắt buộc.');
  end if;

  if revision.estimated_duration_minutes is null
    or cardinality(revision.categories) < 1
    or cardinality(revision.tags) < 1 then
    errors := array_append(
      errors,
      'Cần thời lượng dự kiến, ít nhất một danh mục bản đồ và một tag.'
    );
  end if;

  if private.word_count(revision.short_description) not between 10 and 200
    or private.word_count(revision.long_description) not between 10 and 200 then
    errors := array_append(
      errors,
      'Mô tả Tổng quan phải trong khoảng 10–200 từ.'
    );
  end if;

  if not private.is_http_url(revision.cover_image_url)
    or private.is_blank(revision.cover_image_credit)
    or not private.is_http_url(revision.cover_image_source_url)
    or private.is_blank(revision.cover_image_alt) then
    errors := array_append(
      errors,
      'Ảnh bìa cần URL, credit, nguồn và mô tả thay thế hợp lệ.'
    );
  end if;

  if not private.is_blank(revision.thumbnail_url)
    and (
      not private.is_http_url(revision.thumbnail_url)
      or private.is_blank(revision.thumbnail_credit)
      or not private.is_http_url(revision.thumbnail_source_url)
      or private.is_blank(revision.thumbnail_alt)
    ) then
    errors := array_append(
      errors,
      'Thumbnail đã nhập phải có URL, credit, nguồn và mô tả thay thế.'
    );
  end if;

  if private.is_blank(revision.hook_media_url)
    or private.is_blank(revision.hook_media_credit)
    or not private.is_http_url(revision.hook_media_source_url)
    or private.is_blank(revision.hook_media_alt)
    or private.is_blank(revision.hook_title)
    or private.is_blank(revision.hook_caption)
    or (
      revision.hook_media_kind = 'image'
      and not private.is_http_url(revision.hook_media_url)
    )
    or (
      revision.hook_media_kind = 'youtube'
      and not private.is_youtube_url(revision.hook_media_url)
    ) then
    errors := array_append(
      errors,
      'Mở đầu cần ảnh/YouTube, credit, nguồn, alt, tagline và caption hợp lệ.'
    );
  end if;

  if private.is_blank(revision.stamp_name)
    or private.is_blank(revision.stamp_description)
    or not private.is_http_url(revision.stamp_image_url)
    or private.is_blank(revision.stamp_image_credit)
    or not private.is_http_url(revision.stamp_image_source_url)
    or private.is_blank(revision.stamp_image_alt) then
    errors := array_append(
      errors,
      'Dấu mộc cần tên, mô tả, ảnh, credit, nguồn và alt.'
    );
  end if;

  if (
    select count(*) from public.location_quick_facts fact
    where fact.revision_id = validate_location_revision.revision_id
      and fact.is_visible
  ) < 2 then
    errors := array_append(errors, 'Cần ít nhất 2 thông tin nhanh hiển thị.');
  elsif exists (
    select 1 from public.location_quick_facts fact
    where fact.revision_id = validate_location_revision.revision_id
      and fact.is_visible
      and (private.is_blank(fact.label) or private.is_blank(fact.value))
  ) then
    errors := array_append(errors, 'Thông tin nhanh còn thiếu nhãn hoặc giá trị.');
  end if;

  if exists (
    select 1 from public.location_sources source
    where source.revision_id = validate_location_revision.revision_id
      and source.is_visible
      and (
        private.is_blank(source.title)
        or private.is_blank(source.publisher)
        or not private.is_http_url(source.url)
        or source.accessed_at is null
        or (
          source.verification_status = 'verified'
          and source.verified_at is null
        )
      )
  ) then
    errors := array_append(errors, 'Nguồn tham khảo hiển thị còn thiếu dữ liệu.');
  end if;

  if (
    select count(*) from public.location_history item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) < 2 then
    errors := array_append(errors, 'Cần ít nhất 2 mốc lịch sử hiển thị.');
  elsif exists (
    select 1 from public.location_history item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.period_label)
        or private.word_count(item.title) not between 1 and 10
        or private.word_count(item.short_description) not between 10 and 200
        or private.word_count(item.long_description) not between 10 and 200
      )
  ) then
    errors := array_append(errors, 'Mốc lịch sử cần giai đoạn, tiêu đề và mô tả đúng giới hạn từ.');
  end if;

  if (
    select count(*) from public.location_highlights item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) < 2 then
    errors := array_append(errors, 'Cần ít nhất 2 Điểm đến hiển thị.');
  elsif exists (
    select 1 from public.location_highlights item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.name)
        or private.word_count(item.short_description) not between 10 and 200
        or private.word_count(item.long_description) not between 10 and 200
      )
  ) then
    errors := array_append(errors, 'Điểm đến cần tên và mô tả đúng giới hạn từ.');
  end if;

  if (
    select count(*) from public.location_experiences item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) < 1 then
    errors := array_append(errors, 'Cần ít nhất 1 Trải nghiệm hiển thị.');
  elsif exists (
    select 1 from public.location_experiences item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.name)
        or private.word_count(item.short_description) not between 10 and 200
        or private.word_count(item.long_description) not between 10 and 200
      )
  ) then
    errors := array_append(errors, 'Trải nghiệm cần tên và mô tả đúng giới hạn từ.');
  end if;

  if (
    select count(*) from public.location_foods item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) < 1 then
    errors := array_append(errors, 'Cần ít nhất 1 món ăn hiển thị.');
  elsif exists (
    select 1 from public.location_foods item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.name)
        or private.word_count(item.short_description) not between 10 and 200
        or private.word_count(item.long_description) not between 10 and 200
      )
  ) then
    errors := array_append(errors, 'Món ăn cần tên và mô tả đúng giới hạn từ.');
  end if;

  if (
    select count(*) from public.location_fun_facts item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
  ) < 2 then
    errors := array_append(errors, 'Cần ít nhất 2 Fun Facts hiển thị.');
  elsif exists (
    select 1 from public.location_fun_facts item
    where item.revision_id = validate_location_revision.revision_id
      and item.is_visible
      and (
        private.is_blank(item.title)
        or private.word_count(item.fact) not between 10 and 200
      )
  ) then
    errors := array_append(errors, 'Fun Fact cần tiêu đề và nội dung đúng giới hạn từ.');
  end if;

  if private.is_blank(revision.opening_hours)
    or private.is_blank(revision.ticket_price)
    or private.is_blank(revision.recommended_duration)
    or private.is_blank(revision.best_time_to_visit)
    or private.is_blank(revision.accessibility_info)
    or not private.is_http_url(revision.travel_official_source_url)
    or revision.travel_last_verified_at is null
    or not exists (
      select 1 from public.location_transport_options item
      where item.revision_id = validate_location_revision.revision_id
        and item.is_visible
        and not private.is_blank(item.title)
        and not private.is_blank(item.instructions)
    )
    or not exists (
      select 1 from public.location_visitor_notes item
      where item.revision_id = validate_location_revision.revision_id
        and item.is_visible
        and not private.is_blank(item.content)
    ) then
    errors := array_append(errors, 'Thông tin du lịch thực tế còn thiếu.');
  end if;

  select count(*) into quiz_count
  from public.quiz_questions question
  where question.revision_id = validate_location_revision.revision_id
    and question.is_visible;

  if quiz_count not between 5 and 30 then
    errors := array_append(
      errors,
      'Quiz tổng kết cần từ 5 đến 30 câu hỏi hiển thị.'
    );
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and (
        private.is_blank(question.prompt)
        or private.word_count(question.explanation) not between 10 and 200
      )
  ) then
    errors := array_append(errors, 'Câu hỏi cần nội dung và giải thích đúng giới hạn từ.');
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'single_choice'
      and (
        (select count(*) from public.quiz_options answer where answer.question_id = question.id)
          not between 2 and 6
        or (select count(*) from public.quiz_options answer where answer.question_id = question.id and answer.is_correct) <> 1
        or exists (
          select 1 from public.quiz_options answer
          where answer.question_id = question.id
            and private.is_blank(answer.option_text)
        )
      )
  ) then
    errors := array_append(
      errors,
      'Câu một đáp án cần 2–6 lựa chọn và đúng chính xác một đáp án.'
    );
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'true_false'
      and (
        (select count(*) from public.quiz_options answer where answer.question_id = question.id) <> 2
        or (select count(*) from public.quiz_options answer where answer.question_id = question.id and answer.is_correct) <> 1
      )
  ) then
    errors := array_append(errors, 'Câu Đúng/Sai phải có hai lựa chọn.');
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'matching'
      and (
        (select count(*) from public.quiz_matching_pairs answer where answer.question_id = question.id)
          not between 2 and 8
        or exists (
          select 1 from public.quiz_matching_pairs answer
          where answer.question_id = question.id
            and (
              private.is_blank(answer.left_text)
              or private.is_blank(answer.right_text)
            )
        )
      )
  ) then
    errors := array_append(errors, 'Câu nối cặp cần 2–8 cặp hợp lệ.');
  end if;

  if exists (
    select 1 from public.quiz_questions question
    where question.revision_id = validate_location_revision.revision_id
      and question.is_visible
      and question.kind = 'ordering'
      and (
        (select count(*) from public.quiz_ordering_items answer where answer.question_id = question.id)
          not between 2 and 8
        or exists (
          select 1 from public.quiz_ordering_items answer
          where answer.question_id = question.id
            and private.is_blank(answer.item_text)
        )
      )
  ) then
    errors := array_append(errors, 'Câu sắp xếp cần 2–8 mục hợp lệ.');
  end if;

  return errors;
end;
$$;
