import { apiInitializer } from "discourse/lib/api";

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

        // Create wrapper div (needs to be positioned)
        const wrapper = document.createElement('div');
        wrapper.className = 'inline-divtip';
        
        // Create trigger link
        const trigger = document.createElement('a');
        trigger.href = '#';
        trigger.className = 'expand-divtip';
        trigger.role = 'button';
        trigger.textContent = triggerText;
        
        trigger.addEventListener('click', (e) => {
          e.preventDefault();
        });
        
        // Create tooltip content container
        const tooltipBox = document.createElement('div');
        tooltipBox.className = 'divtip-content';
        tooltipBox.innerHTML = divtipContent;
        
        // Assemble
        wrapper.appendChild(trigger);
        wrapper.appendChild(tooltipBox);
        
        // Replace the div with our wrapper
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
