import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content - MODERN WIDGET-FREE APPROACH
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

        // Create inline wrapper for tooltip trigger
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-divtip';
        
        // Create trigger link
        const trigger = document.createElement('a');
        trigger.href = '#';
        trigger.className = 'expand-divtip';
        trigger.role = 'button';
        trigger.innerHTML = triggerText;
        
        // Store content in data attribute for tooltip
        trigger.setAttribute('data-content', divtipContent);
        
        // Prevent default click behavior
        trigger.addEventListener('click', (e) => {
          e.preventDefault();
          // Toggle tooltip visibility
          wrapper.classList.toggle('divtip-open');
        });
        
        // Create tooltip content element
        const tooltip = document.createElement('div');
        tooltip.className = 'divtip-content';
        tooltip.innerHTML = divtipContent;
        
        // Assemble the structure
        wrapper.appendChild(trigger);
        wrapper.appendChild(tooltip);
        
        // Replace the div with our inline tooltip
        if (div.parentNode) {
          div.parentNode.replaceChild(wrapper, div);
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
