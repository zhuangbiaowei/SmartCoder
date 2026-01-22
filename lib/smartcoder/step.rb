# frozen_string_literal: true

module SmartCoder
  Step = Struct.new(
    :step_id,
    :parent_step_id,
    :intent,
    :repo_commit,
    :container_ref,
    :actions,
    :artifacts,
    :summary,
    keyword_init: true
  )
end
