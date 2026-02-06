import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import DTooltip from "float-kit/components/d-tooltip";
import { apiInitializer } from "discourse/lib/api";

class InlineTip extends Component {
  @action
  preventDefault(event) {
    event.preventDefault();
  }

  <template>
    <DTooltip
      @identifier="inline-tip"
      @interactive={{true}}
      @inline={{true}}
      @closeOnScroll={{false}}
      @closeOnClickOutside={{true}}
      @maxWidth={{600}}
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
      // Skip if already processed
      if (!element || element.classList.contains("inline-tips-processed")) {
        return;
      }

      // Find all SPANs with data-tip attribute
      const tipSpans = element.querySelectorAll('span[data-tip]');
      
      if (tipSpans.length === 0) {
        return;
      }

      tipSpans.forEach((span) => {
        // Skip if already processed
        if (span.classList.contains('inline-tip-processed')) {
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

        // Create wrapper span for inline display
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-tip-wrapper';
        
        // Insert wrapper into DOM before rendering
        if (div.parentNode) {
          div.parentNode.insertBefore(wrapper, div);
        }
        
        // Now render the component into the wrapper using inline template
        helper.renderGlimmer(wrapper, InlineTip, {
          triggerText: triggerText,
          tipContent: tipContent
        });
        
        // Remove the original span after rendering
        span.remove();
        
        span.classList.add('inline-tip-processed');
      });
      
      element.classList.add("inline-tips-processed");
    },
    { 
      id: "inline-tips"
    }
  );

  // Add composer toolbar button
  api.addComposerToolbarPopupMenuOption({
    id: "insert-tip",
    icon: "tooltip-icon",
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
