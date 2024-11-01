<template>
  <div
    class="relative flex items-center w-full my-4"
    :class="colorSchemaClass + ' ' + padding"
    :style="{ height: height }"
  >
    <slot>{{ text }}</slot>
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
      default: 'bg-gray-800',
    },
    height: {
      type: String,
      default: '2px',
    },
    padding: {
      type: String,
      default: '',
    },
  },
  computed: {
    colorSchemaClass() {
      return this.colorSchema;
    },
  },
};
</script>

<style scoped></style>
