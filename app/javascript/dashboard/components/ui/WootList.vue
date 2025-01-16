<template>
  <div class="woot-list">
    <ul v-if="items.length" class="woot-list">
      <li v-for="item in items" :key="item.id" class="woot-list-item">
        <slot name="item" :item="item">
          {{ item.name }}
        </slot>
      </li>
    </ul>
    <p v-else class="text-center">Nenhum item encontrado.</p>
  </div>
</template>

<script>
export default {
  name: 'WootList',
  props: {
    items: {
      type: Array,
      required: true,
      default: () => [],
    },
  },
};
</script>

<style scoped>
.woot-list {
  list-style-type: none; /* Remove marcadores padrão */
  padding: 0;
}

.woot-list-item {
  padding: 10px;
  border-bottom: 1px solid #ccc;
}

.default-icon {
  margin-right: 8px; /* Espaço entre o ícone e o texto */
}
</style>
