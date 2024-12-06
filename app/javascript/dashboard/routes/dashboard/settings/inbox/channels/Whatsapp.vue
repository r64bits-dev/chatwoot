<template>
  <div class="wizard-body w-[75%] flex-shrink-0 flex-grow-0 max-w-[75%]">
    <page-header
      :header-title="$t('INBOX_MGMT.ADD.WHATSAPP.TITLE')"
      :header-content="$t('INBOX_MGMT.ADD.WHATSAPP.DESC')"
    />
    <div class="w-[65%] flex-shrink-0 flex-grow-0 max-w-[65%]">
      <label>
        {{ $t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.LABEL') }}
        <select v-model="provider">
          <option value="whatsapp_cloud">
            {{ $t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.WHATSAPP_CLOUD') }}
          </option>
          <option value="twilio">
            {{ $t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.TWILIO') }}
          </option>
          <option value="360dialog">
            {{ $t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.360_DIALOG') }}
          </option>
          <option value="qrcode">
            {{ $t('INBOX_MGMT.ADD.WHATSAPP.PROVIDERS.QR_CODE') }}
          </option>
        </select>
      </label>
    </div>

    <twilio v-if="provider === 'twilio'" type="whatsapp" />
    <three-sixty-dialog-whatsapp v-else-if="provider === '360dialog'" />
    <QRCodeWhatsapp v-else-if="provider === 'qrcode'" />
    <cloud-whatsapp v-else />
  </div>
</template>

<script>
import PageHeader from '../../SettingsSubPageHeader.vue';
import Twilio from './Twilio.vue';
import ThreeSixtyDialogWhatsapp from './360DialogWhatsapp.vue';
import CloudWhatsapp from './CloudWhatsapp.vue';
import QRCodeWhatsapp from './QRCodeWhatsapp.vue';

export default {
  components: {
    PageHeader,
    Twilio,
    ThreeSixtyDialogWhatsapp,
    CloudWhatsapp,
    QRCodeWhatsapp,
  },
  data() {
    return {
      provider: 'whatsapp_cloud',
    };
  },
};
</script>
