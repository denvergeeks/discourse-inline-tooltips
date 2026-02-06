import { apiInitializer } from "discourse/lib/api";
import { tooltip } from "discourse/lib/d-tooltip";

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content
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

        // Create trigger link
        const trigger = document.createElement('a');
        trigger.href = '#';
        trigger.className = 'expand-tip';
        trigger.role = 'button';
        trigger.innerHTML = triggerText;
        trigger.dataset.tipContent = tipContent;
        
        // Prevent default click behavior
        trigger.addEventListener('click', (e) => {
          e.preventDefault();
        });
        
        // Create wrapper
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-tip';
        wrapper.appendChild(trigger);
        
        // Apply tooltip using Discourse's tooltip helper
        tooltip(trigger, {
          identifier: 'inline-tip',
          interactive: true,
          closeOnScroll: false,
          closeOnClickOutside: true,
          content: tipContent
        });

        // Replace the span
        if (span.parentNode) {
          span.parentNode.replaceChild(wrapper, span);
        }
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
