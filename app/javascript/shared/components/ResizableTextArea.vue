<template>
  <textarea
    ref="textarea"
    :placeholder="placeholder"
    :rows="rows"
    :value="value"
    @input="onInput"
    @focus="onFocus"
    @keyup="onKeyup"
    @blur="onBlur"
  />
</template>

<script>
import {
  appendSignature,
  removeSignature,
  appendDisplayName,
  removeDisplayName,
  extractTextFromMarkdown,
} from 'dashboard/helper/editorHelper';
import { createTypingIndicator } from '@chatwoot/utils';

const TYPING_INDICATOR_IDLE_TIME = 4000;
export default {
  props: {
    placeholder: {
      type: String,
      default: '',
    },
    value: {
      type: String,
      default: '',
    },
    minHeight: {
      type: Number,
      default: 2,
    },
    signature: {
      type: String,
      default: '',
    },
    rows: {
      type: Number,
      default: 2,
    },
    // add this as a prop, so that we won't have to include uiSettingsMixin
    sendWithSignature: {
      type: Boolean,
      default: false,
    },
    // allowSignature is a kill switch, ensuring no signature methods are triggered except when this flag is true
    allowSignature: {
      type: Boolean,
      default: false,
    },
    displayName: {
      type: String,
      default: '',
    },
    // add this as a prop, so that we won't have to include uiSettingsMixin
    sendWithDisplayName: {
      type: Boolean,
      default: false,
    },
    // allowDisplayName is a kill switch, ensuring no display name methods are triggered except when this flag is true
    allowDisplayName: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      typingIndicator: createTypingIndicator(
        () => {
          this.$emit('typing-on');
        },
        () => {
          this.$emit('typing-off');
        },
        TYPING_INDICATOR_IDLE_TIME
      ),
    };
  },
  computed: {
    cleanedSignature() {
      // clean the signature, this will ensure that we don't have
      // any markdown formatted text in the signature
      return extractTextFromMarkdown(this.signature);
    },
    cleanedDisplayName() {
      // clean the display name, this will ensure that we don't have
      // any markdown formatted text in the display name
      return extractTextFromMarkdown(this.displayName);
    },
  },
  watch: {
    value() {
      this.resizeTextarea();
      // 🚨 watch triggers every time the value is changed, we cannot set this to focus then
      // when this runs, it sets the cursor to the end of the body, ignoring the signature
      // Suppose if someone manually set the cursor to the middle of the body
      // and starts typing, the cursor will be set to the end of the body
      // A surprise cursor jump? Definitely not user-friendly.
      if (document.activeElement !== this.$refs.textarea) {
        this.$nextTick(() => {
          this.setCursor();
        });
      }
    },
    sendWithSignature(newValue) {
      if (this.allowSignature) {
        this.toggleSignatureInEditor(newValue);
      }
    },
    sendWithDisplayName(newValue) {
      if (this.allowDisplayName) {
        this.toggleDisplayNameInEditor(newValue);
      }
    },
  },
  mounted() {
    this.$nextTick(() => {
      if (this.value) {
        this.resizeTextarea();
        this.setCursor();
      } else {
        this.focus();
      }
    });
  },
  methods: {
    resizeTextarea() {
      this.$el.style.height = 'auto';
      if (!this.value) {
        this.$el.style.height = `${this.minHeight}rem`;
      } else {
        this.$el.style.height = `${this.$el.scrollHeight}px`;
      }
    },
    // The toggleSignatureInEditor gets the new value from the
    // watcher, this means that if the value is true, the signature
    // is supposed to be added, else we remove it.
    toggleSignatureInEditor(signatureEnabled) {
      const valueWithSignature = signatureEnabled
        ? appendSignature(this.value, this.cleanedSignature)
        : removeSignature(this.value, this.cleanedSignature);

      this.$emit('input', valueWithSignature);

      this.$nextTick(() => {
        this.resizeTextarea();
        this.setCursor();
      });
    },
    // The toggleDisplayNameInEditor gets the new value from the
    // watcher, this means that if the value is true, the display name
    // is supposed to be added, else we remove it.
    toggleDisplayNameInEditor(displayNameEnabled) {
      const valueWithDisplayName = displayNameEnabled
        ? appendDisplayName(this.value, this.cleanedDisplayName)
        : removeDisplayName(this.value, this.cleanedDisplayName);

      this.$emit('input', valueWithDisplayName);

      this.$nextTick(() => {
        this.resizeTextarea();
        this.setCursor();
      });
    },
    setCursor() {
      const bodyWithoutSignature = removeSignature(
        this.value,
        this.cleanedSignature
      );

      // only trim at end, so if there are spaces at the start, those are not removed
      const bodyEndsAt = bodyWithoutSignature.trimEnd().length;
      const textarea = this.$refs.textarea;

      if (textarea) {
        textarea.focus();
        textarea.setSelectionRange(bodyEndsAt, bodyEndsAt);
      }
    },
    onInput(event) {
      this.$emit('input', event.target.value);
      this.resizeTextarea();
    },
    onKeyup() {
      this.typingIndicator.start();
    },
    onBlur() {
      this.typingIndicator.stop();
      this.$emit('blur');
    },
    onFocus() {
      this.$emit('focus');
    },
    focus() {
      if (this.$refs.textarea) this.$refs.textarea.focus();
    },
  },
};
</script>
