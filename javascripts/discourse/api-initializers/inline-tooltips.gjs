import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import DTooltip from "float-kit/components/d-tooltip";
import { apiInitializer } from "discourse/lib/api";
import I18n from "discourse-i18n";

class InlineTip extends Component {
  @action
  preventDefault(event) {
    event.preventDefault();
  }

  <template>
    <DTooltip
      @identifier="inline-tip"
      @interactive={{true}}
      @closeOnScroll={{false}}
      @closeOnClickOutside={{true}}
    >
      <:trigger>
        <a
          class="expand-tip"
          href
          role="button"
          {{on "click" this.preventDefault}}
        >{{htmlSafe @data.triggerText}}</a>
      </:trigger>
      <:content>
        {{htmlSafe @data.tipContent}}
      </:content>
    </DTooltip>
  </template>
}

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content
  api.decorateCookedElement(
    (element, helper) => {
      if (!element || element.classList.contains("inline-tips-processed")) {
        return;
      }

      if (!helper?.widget) {
        return;
      }

      // Find all spans with data-tip attribute
      const tipSpans = element.querySelectorAll('span[data-tip]');
      
      if (tipSpans.length === 0) {
        return;
      }

      tipSpans.forEach((span) => {
        // Skip if already processed
        if (span.classList.contains('inline-tip')) {
          return;
        }
        
        const triggerText = span.getAttribute('data-tip');
        
        if (!triggerText) {
          return;
        }

        // Get the content (innerHTML of the span)
        const tipContent = span.innerHTML.trim();
        
        if (!tipContent) {
          return;
        }

        // Create wrapper for tooltip
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-tip';
        
        // Use the new renderInto method instead of renderGlimmer
        api.renderInto(wrapper, InlineTip, {
          triggerText: triggerText,
          tipContent: tipContent
        });

        // Replace the span with our tooltip
        span.parentNode?.replaceChild(wrapper, span);
      });
      
      element.classList.add("inline-tips-processed");
    },
    { id: "inline-tips", onlyStream: true }
  );

  // Add composer toolbar button
  api.addComposerToolbarPopupMenuOption({
    id: "insert-tip",
    icon: "circle-info",
    label: "insert_tooltip_label",
    action(toolbarEvent) {
      const selected = toolbarEvent.selected;
      const triggerText = selected.value || "trigger text";
      
      const insertion = `<span data-tip="${triggerText}">

Tooltip content with **markdown** and <strong>HTML</strong>

</span>`;

      toolbarEvent.addText(insertion);
    }
  });
});
