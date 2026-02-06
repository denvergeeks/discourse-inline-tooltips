import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.14.0", (api) => {
  // Decorate cooked content
  api.decorateCookedElement(
    (element) => {
      if (!element || element.classList.contains("inline-tips-processed")) {
        return;
      }

      const tipSpans = element.querySelectorAll('span[data-tip]');
      
      if (tipSpans.length === 0) {
        return;
      }

      tipSpans.forEach((span) => {
        if (span.classList.contains('inline-tip')) {
          return;
        }
        
        const triggerText = span.getAttribute('data-tip');
        const tipContent = span.innerHTML.trim();
        
        if (!triggerText || !tipContent) {
          return;
        }

        const wrapper = document.createElement('span');
        wrapper.className = 'inline-tip';
        wrapper.setAttribute('data-tooltip-content', tipContent);
        
        const trigger = document.createElement('a');
        trigger.href = '#';
        trigger.className = 'expand-tip';
        trigger.innerHTML = triggerText;
        trigger.onclick = (e) => {
          e.preventDefault();
          wrapper.classList.toggle('tip-open');
        };
        
        const tooltip = document.createElement('span');
        tooltip.className = 'tip-content';
        tooltip.innerHTML = tipContent;
        
        wrapper.appendChild(trigger);
        wrapper.appendChild(tooltip);
        
        if (span.parentNode) {
          span.parentNode.replaceChild(wrapper, span);
        }
      });
      
      element.classList.add("inline-tips-processed");
    },
    { id: "inline-tips" }
  );

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
