<template>
  <div class="woot-card">
    <div class="woot-card-header">
      <slot name="header" />
      <div v-if="$slots.controls" class="controls">
        <slot name="controls" />
      </div>
    </div>
    <div class="woot-card-body">
      <slot name="body" />
    </div>
    <div v-if="$slots.footer" class="woot-card-footer">
      <slot name="footer" />
    </div>
  </div>
</template>

<script>
export default {
  name: 'WootCard',
};
</script>

<style scoped lang="scss">
.woot-card {
  @apply bg-white dark:bg-slate-800 border-slate-75 dark:border-slate-700;

  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.woot-card-header {
  grid-template-columns: repeat(auto-fit, minmax(max-content, 50%));
  gap: var(--space-small) 0px;
  @apply grid flex-grow w-full mb-6;
  padding: 16px;

  .title {
    @apply flex items-center flex-row;
    h5 {
      @apply mb-0 text-slate-800 dark:text-slate-100;
    }
  }

  .controls {
    @apply flex flex-row items-center justify-end gap-2;
    transition: opacity 0.2s ease-in-out;
    @apply opacity-20;
    justify-self: end;
  }

  &:hover .controls {
    @apply opacity-100;
  }
}

.woot-card-body {
  @apply p-6;

  .metric-content {
    @apply pb-2;
    .heading {
      @apply text-base text-slate-700 dark:text-slate-100;
    }
    .metric {
      @apply text-woot-800 dark:text-woot-300 text-3xl mb-0 mt-1;
    }
  }
}

.woot-card-footer {
  @apply p-4 bg-slate-50 dark:bg-slate-800;
}
</style>
