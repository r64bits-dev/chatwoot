<template>
  <div
    class="inbox--name inline-flex items-center py-0.5 px-0 leading-3 font-medium bg-none text-slate-600 dark:text-slate-500 text-xxs my-0 mx-2.5"
  >
    <fluent-icon class="mr-0.5 rtl:ml-0.5 rtl:mr-0" icon="people" size="12" />
    {{ team.name }}
  </div>
</template>
<script>
export default {
  props: {
    team: {
      type: Object,
      default: () => {},
    },
  },
};
</script>
