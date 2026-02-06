import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content
  api.decorateCookedElement(
    (element) => {
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

        // Create inline wrapper
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-divtip';
        
        // Create trigger link with Float Kit data attributes
        const trigger = document.createElement('span');
        trigger.className = 'fk-d-tooltip__trigger';
        trigger.setAttribute('data-identifier', 'inline-divtip');
        trigger.setAttribute('data-trigger', '');
        trigger.setAttribute('role', 'button');
        trigger.setAttribute('aria-expanded', 'false');
        
        const triggerContainer = document.createElement('span');
        triggerContainer.className = 'fk-d-tooltip__trigger-container';
        
        const triggerLink = document.createElement('a');
        triggerLink.href = '#';
        triggerLink.className = 'expand-divtip';
        triggerLink.role = 'button';
        triggerLink.textContent = triggerText;
        triggerLink.addEventListener('click', (e) => {
          e.preventDefault();
        });
        
        triggerContainer.appendChild(triggerLink);
        trigger.appendChild(triggerContainer);
        
        // Create the tooltip content element (hidden, will be shown by Float Kit)
        const tooltipContent = document.createElement('div');
        tooltipContent.className = 'fk-d-tooltip__content';
        tooltipContent.setAttribute('data-identifier', 'inline-divtip');
        tooltipContent.style.display = 'none';
        
        const tooltipInner = document.createElement('div');
        tooltipInner.className = 'fk-d-tooltip__inner-content';
        tooltipInner.innerHTML = divtipContent; // HTML content goes here
        
        tooltipContent.appendChild(tooltipInner);
        
        wrapper.appendChild(trigger);
        wrapper.appendChild(tooltipContent);
        
        // Replace the div with our inline tooltip
        if (div.parentNode) {
          div.parentNode.replaceChild(wrapper, div);
        }
        
        // Initialize Float Kit after DOM insertion
        schedule('afterRender', () => {
          if (api.container) {
            try {
              const menu = api.container.lookup('service:menu');
              if (menu && menu.register) {
                // Register with Float Kit's menu service
                menu.register(trigger, {
                  identifier: 'inline-divtip',
                  component: tooltipContent,
                  interactive: true,
                  triggers: ['click', 'hover'],
                  untriggers: ['click', 'hover'],
                  offset: 10
                });
              }
            } catch (e) {
              // Silently fail - tooltip still works via CSS
              console.debug("Float Kit service not available:", e);
            }
          }
        });
        
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
