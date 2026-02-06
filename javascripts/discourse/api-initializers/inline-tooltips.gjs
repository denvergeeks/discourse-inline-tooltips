import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import DTooltip from "float-kit/components/d-tooltip";
import { apiInitializer } from "discourse/lib/api";

class InlineDivtip extends Component {
  @action
  preventDefault(event) {
    event.preventDefault();
  }

  <template>
    <DTooltip
      @identifier="inline-divtip"
      @interactive={{true}}
      @closeOnScroll={{false}}
      @closeOnClickOutside={{true}}
      @maxWidth={{600}}
    >
      <:trigger>
        <a
          class="expand-divtip"
          href
          role="button"
          {{on "click" this.preventDefault}}
        >{{htmlSafe @data.triggerText}}</a>
      </:trigger>
      <:content>
        {{htmlSafe @data.divtipContent}}
      </:content>
    </DTooltip>
  </template>
}

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content
  api.decorateCookedElement(
    (element, helper) => {
      // Skip if already processed
      if (!element || element.classList.contains("inline-divtips-processed")) {
        return;
      }

      // Find all DIVs with data-divtip attribute
      const tipDivs = element.querySelectorAll('div[data-divtip]');
      
      if (tipDivs.length === 0) {
        return;
      }

      tipDivs.forEach((div) => {
        // Skip if already processed
        if (div.classList.contains('inline-divtip-processed')) {
          return;
        }
        
        const triggerText = div.getAttribute('data-divtip');
        
        if (!triggerText) {
          return;
        }

        // Get the content (innerHTML of the div) - this is already cooked HTML
        const divtipContent = div.innerHTML.trim();
        
        if (!divtipContent) {
          return;
        }

        // Create wrapper span
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-divtip-wrapper';
        
        // Use helper.renderGlimmer to render the component
        const componentElement = helper.renderGlimmer(wrapper, InlineDivtip, {
          triggerText: triggerText,
          divtipContent: divtipContent
        });
        
        // Replace the div with our component
        if (div.parentNode) {
          div.parentNode.replaceChild(componentElement, div);
        }
        
        div.classList.add('inline-divtip-processed');
      });
      
      element.classList.add("inline-divtips-processed");
    },
    { 
      id: "inline-divtips"
    }
  );

  // Add composer toolbar button
  api.addComposerToolbarPopupMenuOption({
    id: "insert-divtip",
    icon: "circle-info",
    label: "insert_tooltip_label",
    action(toolbarEvent) {
      const selected = toolbarEvent.selected;
      const triggerText = selected.value || "trigger text";
      
      const insertion = `<div data-divtip="${triggerText}">

Tooltip content with **markdown** and <strong>HTML</strong>

</div>`;

      toolbarEvent.addText(insertion);
    }
  });
});
