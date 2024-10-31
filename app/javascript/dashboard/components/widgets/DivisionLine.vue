<template>
  <div
    class="w-full border-b border-gray-200 dark:border-gray-700 my-4"
    :style="divisionLineStyle"
  >
    <span class="text-xs text-center text-white">{{ text }}</span>
  </div>
</template>

<script>
export default {
  name: 'DivisionLine',
  props: {
    text: {
      type: String,
      default: '',
    },
    colorSchema: {
      type: String,
      default: '',
    },
    height: {
      type: String,
      default: '1px',
    },
  },
  computed: {
    divisionLineStyle() {
      return {
        height: this.height,
        backgroundColor: this.colorSchema,
      };
    },
  },
};
</script>

<style></style>
