<template>
  <div class="flex items-center">
    <button
      type="button"
      :class="[
        'relative inline-flex items-center flex-shrink-0 h-6 w-11 rounded-full cursor-pointer transition-colors ease-in-out duration-200 focus:outline-none focus:ring-2 focus:ring-offset-2',
        {
          'bg-black-400': !value,
          'bg-woot-400': value,
        },
      ]"
      role="switch"
      :aria-checked="value"
      @click="toggle"
    >
      <span
        aria-hidden="true"
        :class="[
          'pointer-events-none inline-block h-4 w-4 rounded-full bg-white shadow transform ring-0 transition ease-in-out duration-200 mt-0.5',
          value ? 'translate-x-6' : 'translate-x-1',
        ]"
      />
    </button>
    <span v-if="label" class="ml-3 text-sm text-gray-700">
      {{ label }}
    </span>
  </div>
</template>

<script>
export default {
  name: 'WootToggle',
  props: {
    value: {
      type: Boolean,
      default: false,
    },
    label: {
      type: String,
      default: '',
    },
  },
  methods: {
    toggle() {
      this.$emit('input', !this.value);
    },
  },
};
</script>
