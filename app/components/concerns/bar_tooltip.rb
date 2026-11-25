module BarTooltip
  COLUMN_ACTIONS = 'mouseenter->bar-tooltip#show mouseleave->bar-tooltip#hide ' \
                   'focus->bar-tooltip#show blur->bar-tooltip#hide ' \
                   'click->bar-tooltip#toggle keydown.enter->bar-tooltip#toggle'.freeze
end
