import { apiInitializer } from "discourse/lib/api";
import { bind } from "discourse-common/utils/decorators";

export default apiInitializer("1.14.0", (api) => {
  // Store references to active tooltips
  const tooltipInstances = new Map();

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

        // Get the content (innerHTML of the div)
        const divtipContent = div.innerHTML.trim();
        
        if (!divtipContent) {
          return;
        }

        // Create inline wrapper
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-divtip';
        
        // Create trigger link
        const trigger = document.createElement('a');
        trigger.href = '#';
        trigger.className = 'expand-divtip';
        trigger.role = 'button';
        trigger.innerHTML = triggerText;
        trigger.setAttribute('data-tooltip', divtipContent);
        
        // Use Float Kit's tooltip attribute
        trigger.setAttribute('data-tooltip-interactive', 'true');
        trigger.setAttribute('data-tooltip-max-width', '600');
        trigger.setAttribute('data-identifier', 'inline-divtip');
        
        // Prevent default click behavior
        trigger.addEventListener('click', (e) => {
          e.preventDefault();
        });
        
        wrapper.appendChild(trigger);
        
        // Replace the div with our inline tooltip
        if (div.parentNode) {
          div.parentNode.replaceChild(wrapper, div);
        }
        
        // Initialize Float Kit tooltip programmatically
        if (api.container) {
          try {
            const tooltipService = api.container.lookup('service:tooltip');
            if (tooltipService && tooltipService.register) {
              tooltipService.register(trigger, {
                identifier: 'inline-divtip',
                interactive: true,
                closeOnScroll: false,
                closeOnClickOutside: true,
                maxWidth: 600,
                content: divtipContent,
                triggers: ['click', 'hover']
              });
              
              tooltipInstances.set(trigger, tooltipService);
            }
          } catch (e) {
            console.warn("Could not initialize tooltip service:", e);
          }
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
  
  // Cleanup on teardown
  api.onPageChange(() => {
    tooltipInstances.forEach((service, element) => {
      if (service.unregister) {
        service.unregister(element);
      }
    });
    tooltipInstances.clear();
  });
});
