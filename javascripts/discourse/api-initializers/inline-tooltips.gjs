import { apiInitializer } from "discourse/lib/api";
import { schedule } from "@ember/runloop";

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content - Pure DOM approach, no widgets
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
        
        // Store content in data attribute
        trigger.setAttribute('data-content', tipContent);
        trigger.setAttribute('data-tooltip', tipContent);
        
        // Prevent default click behavior
        trigger.addEventListener('click', (e) => {
          e.preventDefault();
        });
        
        // Create wrapper
        const wrapper = document.createElement('span');
        wrapper.className = 'inline-tip';
        wrapper.appendChild(trigger);
        
        // Use Discourse's FloatKit tooltip
        schedule('afterRender', () => {
          if (window.FloatKit) {
            window.FloatKit.tooltip(trigger, {
              identifier: 'inline-tip',
              interactive: true,
              closeOnScroll: false,
              closeOnClickOutside: true,
              content: tipContent,
              triggers: ['click', 'hover']
            });
          } else {
            // Fallback: add title attribute
            trigger.setAttribute('title', tipContent);
          }
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
