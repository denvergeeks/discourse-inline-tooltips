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
    <span class="inline-tip">
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
    </span>
  </template>
}

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content - MODERN WIDGET-FREE APPROACH
  api.decorateCookedElement(
    (element) => {
      // Skip if already processed
      if (!element || element.classList.contains("inline-tips-processed")) {
        return;
      }

      // Find all spans with data-tip attribute
      const tipSpans = element.querySelectorAll('span[data-tip]');
      
      if (tipSpans.length === 0) {
        return;
      }

      // Process each tooltip span
      const componentsToRender = [];
      
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

        // Create wrapper for tooltip
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-tip-container';
        
        // Store data for rendering
        componentsToRender.push({
          wrapper,
          data: {
            triggerText: triggerText,
            tipContent: tipContent
          }
        });

        // Replace the span with our wrapper
        if (span.parentNode) {
          span.parentNode.replaceChild(wrapper, span);
        }
        
        span.classList.add('inline-tip-processed');
      });
      
      // Render all components using the container lookup method
      if (componentsToRender.length > 0 && api.container) {
        const glimmerHelper = api.container.lookup("service:glimmer-component-manager");
        
        if (glimmerHelper) {
          componentsToRender.forEach(({ wrapper, data }) => {
            try {
              // Create a mounting point
              const mountPoint = document.createElement('div');
              mountPoint.style.display = 'inline';
              wrapper.appendChild(mountPoint);
              
              // Mount the component
              api.renderInOutlet
                ? api.renderInOutlet(wrapper, InlineTip, { data })
                : api._registerPluginOutletComponent?.(wrapper, InlineTip, { data });
            } catch (e) {
              console.error("Error rendering inline tooltip:", e);
            }
          });
        }
      }
      
      element.classList.add("inline-tips-processed");
    },
    { 
      id: "inline-tips"
    }
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
