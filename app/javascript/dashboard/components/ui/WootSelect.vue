<template>
  <div class="woot-select" :class="className">
    <label :for="id">{{ label }}</label>
    <select :id="id" v-model="selected" @change="updateValue">
      <option v-for="option in options" :key="option.id" :value="option.id">
        {{ option.value }}
      </option>
    </select>
  </div>
</template>

<script>
export default {
  name: 'WootSelect',
  props: {
    value: {
      type: [String, Number],
      default: null,
    },
    className: {
      type: String,
      default: '',
    },
    options: {
      type: Array,
      required: true,
    },
    label: {
      type: String,
      default: '',
    },
    id: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      selected: this.value,
    };
  },
  watch: {
    value(newValue) {
      this.selected = newValue;
    },
  },
  methods: {
    updateValue() {
      this.$emit('change', this.selected);
    },
  },
};
</script>

<style scoped>
.woot-select {
}
</style>
