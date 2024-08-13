<template>
  <div
    class="w-full text-slate-800 dark:text-slate-100 h-full border-b border-solid border-slate-50 dark:border-slate-800 flex items-center justify-between"
  >
    <div class="flex flex-col">
      <span
        class="text-base font-medium leading-6 text-slate-800 dark:text-slate-100 h-full w-full truncate"
        >{{ ticket.title }}
      </span>
      <span class="text-slate-600 dark:text-slate-300 text-sm font-thin">
        {{ ticket.description || '---' }}
      </span>
    </div>
    <div class="flex">
      <span class="text-slate-600 dark:text-slate-300 text-sm">
        {{ $t(`TICKETS.STATUS.${status}`) || '---' }}
      </span>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    ticket: {
      type: Object,
      required: true,
    },
  },
  computed: {
    status() {
      return this.ticket.status.toUpperCase();
    },
  },
};
</script>
