<template>
  <div class="woot-card">
    <div class="woot-card-header">
      <slot v-if="$slots.header" name="header" />
      <div v-else-if="header" class="card-header">
        <div class="card-header--title-area">
          <h3 class="text-xl font-medium">{{ header }}</h3>
          <span v-if="headerStatus.message" :class="getHeaderStatusClass">
            <span class="ellipse" /><span>{{ headerStatus.message }}</span>
          </span>
        </div>
        <div v-if="subHeader" class="card-header--sub-header">
          <p>{{ subHeader }}</p>
        </div>
      </div>
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
  props: {
    header: {
      type: String,
      default: '',
    },
    subHeader: {
      type: String,
      default: '',
    },
    headerStatus: {
      type: Object,
      default: () => ({
        status: 'pending',
        message: '',
      }),
    },
  },
  computed: {
    getHeaderStatusClass() {
      const { status } = this.headerStatus;
      return `${status}`;
    },
  },
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
  margin-bottom: 0;

  .card-header--title-area {
    @apply flex items-center;

    .success {
      background: rgba(37, 211, 102, 0.1);
      @apply flex flex-row items-center pr-2 pl-2 m-1 text-green-400 dark:text-green-400 text-xs;

      .ellipse {
        @apply bg-green-400 dark:bg-green-400 h-1 w-1 rounded-full mr-1 rtl:mr-0 rtl:ml-0;
      }
    }

    .pending {
      background: rgba(255, 193, 7, 0.1);
      @apply flex flex-row items-center pr-2 pl-2 m-1 text-yellow-400 dark:text-yellow-400 text-xs;

      .ellipse {
        @apply bg-yellow-400 dark:bg-yellow-400 h-1 w-1 rounded-full mr-1 rtl:mr-0 rtl:ml-0;
      }
    }

    .error {
      background: rgba(239, 68, 68, 0.1);
      @apply flex flex-row items-center pr-2 pl-2 m-1 text-red-400 dark:text-red-400 text-xs;

      .ellipse {
        @apply bg-red-400 dark:bg-red-400 h-1 w-1 rounded-full mr-1 rtl:mr-0 rtl:ml-0;
      }
    }
  }

  .card-header--sub-header {
    @apply text-sm text-slate-500 dark:text-slate-400;
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
