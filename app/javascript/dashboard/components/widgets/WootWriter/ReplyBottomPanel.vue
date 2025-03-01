<template>
  <div class="bottom-box" :class="wrapClass">
    <div class="left-wrap">
      <woot-button
        v-tooltip.top-end="$t('CONVERSATION.REPLYBOX.TIP_EMOJI_ICON')"
        :title="$t('CONVERSATION.REPLYBOX.TIP_EMOJI_ICON')"
        icon="emoji"
        emoji="😊"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        @click="toggleEmojiPicker"
      />
      <file-upload
        ref="upload"
        v-tooltip.top-end="$t('CONVERSATION.REPLYBOX.TIP_ATTACH_ICON')"
        input-id="conversationAttachment"
        :size="4096 * 4096"
        :accept="allowedFileTypes"
        :multiple="enableMultipleFileUpload"
        :drop="enableDragAndDrop"
        :drop-directory="false"
        :data="{
          direct_upload_url: '/rails/active_storage/direct_uploads',
          direct_upload: true,
        }"
        @input-file="onFileUpload"
      >
        <woot-button
          v-if="showAttachButton"
          class-names="button--upload"
          :title="$t('CONVERSATION.REPLYBOX.TIP_ATTACH_ICON')"
          icon="attach"
          emoji="📎"
          color-scheme="secondary"
          variant="smooth"
          size="small"
        />
      </file-upload>
      <woot-button
        v-if="showEditorToggle"
        v-tooltip.top-end="$t('CONVERSATION.REPLYBOX.TIP_FORMAT_ICON')"
        icon="quote"
        emoji="🖊️"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        @click="$emit('toggle-editor')"
      />
      <woot-button
        v-if="showAudioPlayStopButton"
        :icon="audioRecorderPlayStopIcon"
        emoji="🎤"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        @click="toggleAudioRecorderPlayPause"
      >
        <span>{{ recordingAudioDurationText }}</span>
      </woot-button>
      <woot-button
        v-if="showMessageSignatureButton"
        v-tooltip.top-end="signatureToggleTooltip"
        icon="signature"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        :title="signatureToggleTooltip"
        @click="toggleMessageSignature"
      />
      <woot-button
        v-if="showDisplayNameButton"
        v-tooltip.top-end="displayNameToggleTooltip"
        icon="draw-text"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        :title="displayNameToggleTooltip"
        @click="toggleMessageDisplayName"
      />
      <woot-button
        v-if="hasWhatsappTemplates"
        v-tooltip.top-end="'Whatsapp Templates'"
        icon="whatsapp"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        :title="'Whatsapp Templates'"
        @click="$emit('selectWhatsappTemplate')"
      />
      <video-call-button
        v-if="(isAWebWidgetInbox || isAPIInbox) && !isOnPrivateNote"
        :conversation-id="conversationId"
      />
      <AIAssistanceButton
        :conversation-id="conversationId"
        :is-private-note="isOnPrivateNote"
        :message="message"
        @replace-text="replaceText"
      />
      <transition name="modal-fade">
        <div
          v-show="$refs.upload && $refs.upload.dropActive"
          class="fixed top-0 bottom-0 left-0 right-0 z-20 flex flex-col items-center justify-center w-full h-full gap-2 text-slate-600 dark:text-slate-200 bg-white_transparent dark:bg-black_transparent"
        >
          <fluent-icon icon="cloud-backup" size="40" />
          <h4 class="page-sub-title text-slate-600 dark:text-slate-200">
            {{ $t('CONVERSATION.REPLYBOX.DRAG_DROP') }}
          </h4>
        </div>
      </transition>
      <woot-button
        v-if="enableInsertArticleInReply"
        v-tooltip.top-end="$t('HELP_CENTER.ARTICLE_SEARCH.OPEN_ARTICLE_SEARCH')"
        icon="document-text-link"
        color-scheme="secondary"
        variant="smooth"
        size="small"
        :title="$t('HELP_CENTER.ARTICLE_SEARCH.OPEN_ARTICLE_SEARCH')"
        @click="toggleInsertArticle"
      />
    </div>
    <div class="right-wrap">
      <woot-button
        v-if="showAudioRecorderButton"
        v-tooltip.top-end="$t('CONVERSATION.REPLYBOX.TIP_AUDIORECORDER_ICON')"
        :icon="!isRecordingAudio ? 'microphone' : 'microphone-off'"
        emoji="🎤"
        :color-scheme="!isRecordingAudio ? 'alert' : 'danger'"
        variant="smooth"
        size="small"
        class="mr-2"
        @click="toggleAudioRecorder"
      />
      <woot-button
        size="small"
        :class-names="buttonClass"
        :is-disabled="isSendDisabled" 
        @click="handleSendClick"
      >
        {{ sendButtonText }}
      </woot-button>
    </div>
  </div>
</template>

<script>
import FileUpload from 'vue-upload-component';
import * as ActiveStorage from 'activestorage';
import { hasPressedAltAndAKey } from 'shared/helpers/KeyboardHelpers';
import eventListenerMixins from 'shared/mixins/eventListenerMixins';
import uiSettingsMixin from 'dashboard/mixins/uiSettings';
import inboxMixin from 'shared/mixins/inboxMixin';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';
import {
  ALLOWED_FILE_TYPES,
  ALLOWED_FILE_TYPES_FOR_TWILIO_WHATSAPP,
  ALLOWED_FILE_TYPES_FOR_LINE,
} from 'shared/constants/messages';
import VideoCallButton from '../VideoCallButton.vue';
import AIAssistanceButton from '../AIAssistanceButton.vue';
import { REPLY_EDITOR_MODES } from './constants';
import { mapGetters } from 'vuex';

export default {
  name: 'ReplyBottomPanel',
  components: { FileUpload, VideoCallButton, AIAssistanceButton },
  mixins: [eventListenerMixins, uiSettingsMixin, inboxMixin],
  props: {
    mode: {
      type: String,
      default: REPLY_EDITOR_MODES.REPLY,
    },
    isAssignedToCurrentUser: { // Nova prop
      type: Boolean,
      default: false,
    },
    onSend: {
      type: Function,
      default: () => {},
    },
    sendButtonText: {
      type: String,
      default: '',
    },
    recordingAudioDurationText: {
      type: String,
      default: '',
    },
    inbox: {
      type: Object,
      default: () => ({}),
    },
    showFileUpload: {
      type: Boolean,
      default: false,
    },
    showAudioRecorder: {
      type: Boolean,
      default: false,
    },
    onFileUpload: {
      type: Function,
      default: () => {},
    },
    showEmojiPicker: {
      type: Boolean,
      default: false,
    },
    toggleEmojiPicker: {
      type: Function,
      default: () => {},
    },
    toggleAudioRecorder: {
      type: Function,
      default: () => {},
    },
    toggleAudioRecorderPlayPause: {
      type: Function,
      default: () => {},
    },
    isRecordingAudio: {
      type: Boolean,
      default: false,
    },
    recordingAudioState: {
      type: String,
      default: '',
    },
    isSendDisabled: {
      type: Boolean,
      default: false,
    },
    showEditorToggle: {
      type: Boolean,
      default: false,
    },
    isOnPrivateNote: {
      type: Boolean,
      default: false,
    },
    enableMultipleFileUpload: {
      type: Boolean,
      default: true,
    },
    hasWhatsappTemplates: {
      type: Boolean,
      default: false,
    },
    conversationId: {
      type: Number,
      required: true,
    },
    message: {
      type: String,
      default: '',
    },
    newConversationModalActive: {
      type: Boolean,
      default: false,
    },
    portalSlug: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapGetters({
      accountId: 'getCurrentAccountId',
      isFeatureEnabledonAccount: 'accounts/isFeatureEnabledonAccount',
      currentUser: 'getCurrentUser', // Adicionado para acessar o usuário atual
      currentChat: 'getSelectedChat', // Adicionado para acessar a conversa atual
    }),
    isNote() {
      return this.mode === REPLY_EDITOR_MODES.NOTE;
    },
    wrapClass() {
      return {
        'is-note-mode': this.isNote,
      };
    },
    buttonClass() {
      return {
        warning: this.isNote,
      };
    },
    showAttachButton() {
      return this.showFileUpload || this.isNote;
    },
    showAudioRecorderButton() {
      if (this.isALineChannel) {
        return false;
      }
      const isSafari = /^((?!chrome|android|crios|fxios).)*safari/i.test(
        navigator.userAgent
      );
      return (
        this.isFeatureEnabledonAccount(
          this.accountId,
          FEATURE_FLAGS.VOICE_RECORDER
        ) &&
        this.showAudioRecorder &&
        !isSafari
      );
    },
    showAudioPlayStopButton() {
      return this.showAudioRecorder && this.isRecordingAudio;
    },
    allowedFileTypes() {
      if (this.isATwilioWhatsAppChannel) {
        return ALLOWED_FILE_TYPES_FOR_TWILIO_WHATSAPP;
      }
      if (this.isALineChannel) {
        return ALLOWED_FILE_TYPES_FOR_LINE;
      }
      return ALLOWED_FILE_TYPES;
    },
    enableDragAndDrop() {
      return !this.newConversationModalActive;
    },
    audioRecorderPlayStopIcon() {
      switch (this.recordingAudioState) {
        case 'playing':
          return 'microphone-pause';
        case 'paused':
          return 'microphone-play';
        case 'stopped':
          return 'microphone-play';
        default:
          return 'microphone-stop';
      }
    },
    showMessageSignatureButton() {
      return !this.isOnPrivateNote;
    },
    showDisplayNameButton() {
      return !this.isOnPrivateNote;
    },
    sendWithSignature() {
      return this.fetchSignatureFlagFromUiSettings(this.channelType);
    },
    sendWithDisplayName() {
      return this.fetchDisplayNameFlagFromUiSettings(this.channelType);
    },
    signatureToggleTooltip() {
      return this.sendWithSignature
        ? this.$t('CONVERSATION.FOOTER.DISABLE_SIGN_TOOLTIP')
        : this.$t('CONVERSATION.FOOTER.ENABLE_SIGN_TOOLTIP');
    },
    displayNameToggleTooltip() {
      return this.sendWithDisplayName
        ? this.$t('CONVERSATION.FOOTER.DISABLE_DISPLAY_NAME_TOOLTIP')
        : this.$t('CONVERSATION.FOOTER.ENABLE_DISPLAY_NAME_TOOLTIP');
    },
    enableInsertArticleInReply() {
      const isFeatEnabled = this.isFeatureEnabledonAccount(
        this.accountId,
        FEATURE_FLAGS.INSERT_ARTICLE_IN_REPLY
      );
      return isFeatEnabled && this.portalSlug;
    },
  },
  mounted() {
    ActiveStorage.start();
  },
  methods: {
    handleKeyEvents(e) {
      if (hasPressedAltAndAKey(e)) {
        this.$refs.upload.$children[1].$el.click();
      }
    },
    toggleMessageSignature() {
      this.setSignatureFlagForInbox(this.channelType, !this.sendWithSignature);
    },
    toggleMessageDisplayName() {
      this.setDisplayNameFlagForInbox(this.channelType, !this.sendWithDisplayName);
    },
    replaceText(text) {
      this.$emit('replace-text', text);
    },
    toggleInsertArticle() {
      this.$emit('toggle-insert-article');
    },
    async handleSendClick() {
      const currentUserId = this.currentUser.id;
      const assignee = await this.$store.dispatch('getCurrentAssignee', this.currentChat.id);
      if (currentUserId === assignee.id) {
         this.onSend();
      } else {
        this.showAlert('Você não está atribuído a esta conversa');
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.bottom-box {
  @apply flex justify-between py-3 px-4;

  &.is-note-mode {
    @apply bg-yellow-100 dark:bg-yellow-800;
  }
}

.left-wrap {
  @apply items-center flex gap-2;
}

.right-wrap {
  @apply flex;
}

::v-deep .file-uploads {
  label {
    @apply cursor-pointer;
  }
  &:hover button {
    @apply dark:bg-slate-800 bg-slate-100;
  }
}
</style>