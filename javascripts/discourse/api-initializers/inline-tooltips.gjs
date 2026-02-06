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

        // Create inline wrapper
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-divtip';
        
        // Create trigger link
        const trigger = document.createElement('a');
        trigger.href = '#';
        trigger.className = 'expand-divtip';
        trigger.role = 'button';
        trigger.textContent = triggerText;
        
        // Store the HTML content in a data attribute (we'll parse it on show)
        trigger.setAttribute('data-divtip-html', divtipContent);
        
        trigger.addEventListener('click', (e) => {
          e.preventDefault();
        });
        
        wrapper.appendChild(trigger);
        
        // Replace the div with our inline tooltip
        if (div.parentNode) {
          div.parentNode.replaceChild(wrapper, div);
        }
        
        // Use Tippy.js directly (what Discourse uses for tooltips)
        if (window.tippy) {
          const tippyInstance = window.tippy(trigger, {
            content: divtipContent,
            allowHTML: true,
            interactive: true,
            trigger: 'mouseenter click',
            hideOnClick: false,
            placement: 'top',
            maxWidth: 600,
            theme: 'light-border',
            arrow: true,
            appendTo: document.body,
            onShow(instance) {
              // Create a proper DOM structure for the content
              const contentDiv = document.createElement('div');
              contentDiv.className = 'inline-divtip-content';
              contentDiv.innerHTML = trigger.getAttribute('data-divtip-html');
              instance.setContent(contentDiv);
            }
          });
          
          // Store instance for cleanup
          trigger._tippyInstance = tippyInstance;
        }
        
        div.classList.add('inline-divtip-processed');
      });
      
      element.classList.add("inline-divtips-processed");
    },
    { 
      id: "inline-divtips"
    }
  );

  // Cleanup on page change
  api.onPageChange(() => {
    document.querySelectorAll('.expand-divtip').forEach(trigger => {
      if (trigger._tippyInstance) {
        trigger._tippyInstance.destroy();
        delete trigger._tippyInstance;
      }
    });
  });

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
