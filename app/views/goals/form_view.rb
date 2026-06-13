module Goals
  class FormView < ApplicationView
    def initialize(goal:)
      @goal = goal
      @theme = :blue
    end

    def view_template
      turbo_frame_tag 'modal' do
        div(class: modal_backdrop_classes, data: { controller: 'modal', action: 'mousedown->modal#handleBackgroundClick' }) do
          div(class: "#{modal_content_classes} #{modal_theme_classes(theme: @theme)}") do
            render_header
            render_form
          end
        end
      end
    end

    private

    def render_header
      div(class: modal_header_classes) do
        h2(class: "#{modal_title_classes} #{title_classes(theme: @theme)}") { title_text }
        button(type: 'button', data: { action: 'modal#close' }, class: modal_close_button_classes) { '×' }
      end
    end

    def title_text
      @goal.persisted? ? t('goals.index.form.title_edit') : t('goals.index.form.title_new')
    end

    def form_url
      @goal.persisted? ? helpers.goal_path(@goal) : helpers.goals_path
    end

    def form_method
      @goal.persisted? ? :patch : :post
    end

    def render_form
      form_with(model: @goal, url: form_url, method: form_method, class: 'p-6 space-y-4') do |form|
        kind_select(form)
        money_field(form, :target_amount, label: t('goals.index.form.labels.target_amount'), theme: @theme, required: true)
        date_field(form, :period_start, label: t('goals.index.form.labels.period_start'), theme: @theme)
        date_field(form, :period_end, label: t('goals.index.form.labels.period_end'), theme: @theme)
        metric_select(form)
        render_actions
      end
    end

    def kind_select(form)
      field_wrapper(t('goals.index.form.labels.kind'), theme: @theme) do
        options = Goal::KINDS.map { |kind| [t("goals.index.form.kinds.#{kind}"), kind] }
        render form.select(:kind, options, {}, { class: "#{input_classes(theme: @theme)} bg-white" })
      end
    end

    def metric_select(form)
      field_wrapper(t('goals.index.form.labels.metric'), theme: @theme) do
        options = Goal::METRICS.map { |metric| [t("goals.index.form.metrics.#{metric}"), metric] }
        render form.select(:metric, options, {}, { class: "#{input_classes(theme: @theme)} bg-white" })
      end
    end

    def render_actions
      div(class: 'flex gap-3 pt-4') do
        button(type: 'button', data: { action: 'modal#close' }, class: button_classes(variant: :secondary, full_width: true)) { t('goals.index.form.buttons.cancel') }
        button(type: 'submit', class: "#{button_classes(variant: :primary, full_width: true)} flex items-center justify-center gap-2") do
          render PhlexIcons::Lucide::Save.new(class: 'w-5 h-5')
          span { t('goals.index.form.buttons.save') }
        end
      end
    end
  end
end
