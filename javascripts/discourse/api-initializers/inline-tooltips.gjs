import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { trustHTML } from "@ember/template";
import DTooltip from "float-kit/components/d-tooltip";
import { apiInitializer } from "discourse/lib/api";
import I18n from "I18n";

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
      @maxWidth={{350}}
    >
      <:trigger>
        <a
          class="expand-tip"
          href
          role="button"
          {{on "click" this.preventDefault}}
        >{{trustHTML @data.triggerText}}</a>
      </:trigger>
      <:content>
        {{trustHTML @data.tipContent}}
      </:content>
    </DTooltip>
  </template>
}

export default apiInitializer("1.14.0", (api) => {
  // Register translation for button label
  const locale = I18n.locale || I18n.currentLocale || "en";
  if (!I18n.translations[locale]) {
    I18n.translations[locale] = {};
  }
  if (!I18n.translations[locale].js) {
    I18n.translations[locale].js = {};
  }
  I18n.translations[locale].js.insert_tooltip_label = "Insert Tooltip";

  // Decorate cooked content
  api.decorateCookedElement(
    (element, helper) => {
      // Skip if already processed
      if (!element || element.classList.contains("inline-tips-processed")) {
        return;
      }

      // Find all DIVs with data-divtip attribute
      const tipDivs = element.querySelectorAll('div[data-tip]');
      
      if (tipDivs.length === 0) {
        return;
      }

      tipDivs.forEach((div) => {
        // Skip if already processed
        if (div.classList.contains('inline-tip-processed')) {
          return;
        }
        
        const triggerText = div.getAttribute('data-tip');
        
        if (!triggerText) {
          return;
        }

        // Get the content (innerHTML of the div)
        const tipContent = div.innerHTML.trim();
        
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
        
        // Remove the original div after rendering
        div.remove();
        
        div.classList.add('inline-tip-processed');
      });
      
      element.classList.add("inline-tips-processed");
    },
    { 
      id: "inline-tips"
    }
  );

  // Add composer toolbar button
  api.addComposerToolbarPopupMenuOption({
    id: "insert-tooltip",
    icon: "tooltip-icon",
    label: "insert_tooltip_label",
    action(toolbarEvent) {
      const selected = toolbarEvent.selected;
      const triggerText = selected.value || "trigger text";
      
      const insertion = `<div data-tip="${triggerText}">

Tooltip content with **markdown** and <strong>HTML</strong>

</div>`;

      toolbarEvent.addText(insertion);
    }
  });
});
