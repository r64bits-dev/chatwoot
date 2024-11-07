<template>
  <div :class="getClassName" :style="{ height: height }">
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
    className: {
      type: String,
      default: '',
    },
  },
  computed: {
    colorSchemaClass() {
      return this.colorSchema;
    },
    getClassName() {
      const classList = [this.colorSchemaClass, this.padding];

      if (this.className) {
        classList.push(this.className);
      } else classList.push('relative flex items-center w-full my-4');

      return classList.join(' ');
    },
  },
};
</script>

<style scoped></style>
