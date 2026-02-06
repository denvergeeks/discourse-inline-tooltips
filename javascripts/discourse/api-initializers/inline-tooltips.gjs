import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { htmlSafe } from "@ember/template";
import DTooltip from "discourse/float-kit/components/d-tooltip";
import { apiInitializer } from "discourse/lib/api";
import I18n from "I18n";

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

export default apiInitializer("0.11.1", (api) => {
  // Register translation for button label
  const locale = I18n.locale || I18n.currentLocale || "en";
  if (!I18n.translations[locale]) {
    I18n.translations[locale] = {};
  }
  if (!I18n.translations[locale].js) {
    I18n.translations[locale].js = {};
  }
  I18n.translations[locale].js.insert_tooltip_label = "Insert Tooltip";

  // Decorate cooked content
  api.decorateCookedElement(
    (element, helper) => {
      processTips(element, helper);
    },
    { id: "inline-divtips", onlyStream: true }
  );

  // Add composer toolbar button
  const composerApi = api.composer || api;
  if (composerApi.addComposerToolbarPopupMenuOption) {
    composerApi.addComposerToolbarPopupMenuOption({
      id: "insert-divtip",
      icon: "tooltip-icon",
      label: "insert_tooltip_label",
      action(toolbarEvent) {
        insertTip(toolbarEvent, api);
      }
    });
  }
});

function insertTip(toolbarEvent, api) {
  let model = null;
  
  if (toolbarEvent) {
    model = toolbarEvent.model || 
            toolbarEvent.composer?.model || 
            toolbarEvent.controller?.model;
  }
  
  if (!model && api?.container) {
    try {
      const composer = api.container.lookup("service:composer");
      model = composer?.model;
    } catch (e) {
      // ignore
    }
  }
  
  if (!model) {
    return;
  }

  const reply = model.reply || "";
  const selection = model.replySelection;
  let selectedText = "";

  if (selection?.start !== undefined && selection?.end !== undefined) {
    selectedText = reply.substring(selection.start, selection.end);
  }

  const triggerText = selectedText || "trigger text";
  
  // Use a DIV with special class that users write in markdown
  const insertion = `<div data-divtip="${triggerText}">

Tooltip content with **markdown** and <strong>HTML</strong>

</div>`;

  if (typeof model.appendText === "function") {
    model.appendText(insertion);
  }
}

function processTips(element, helper) {
  if (!element || element.classList.contains("inline-divtips-processed")) {
    return;
  }

  if (!helper?.getModel()) {
    return;
  }

  // Find all DIVs with data-divtip attribute
  const tipDivs = element.querySelectorAll('div[data-divtip]');
  
  if (tipDivs.length === 0) {
    return;
  }

  tipDivs.forEach((div) => {
    // Skip if already processed
    if (div.classList.contains('inline-divtip')) {
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

    // Create tooltip component
    const divtipComponent = document.createElement('span');
    divtipComponent.className = 'inline-divtip';
    
    helper.renderGlimmer(divtipComponent, InlineDivtip, {
      triggerText: triggerText,
      divtipContent: divtipContent
    });

    // Replace the div with our tooltip
    div.parentNode.replaceChild(divtipComponent, span);
  });
  
  element.classList.add("inline-divtips-processed");
}
