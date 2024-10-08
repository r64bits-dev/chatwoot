<template>
  <transition name="popover-animation">
    <div class="article-settings--container">
      <h3 class="text-base text-slate-800 dark:text-slate-100">
        {{ $t('HELP_CENTER.ARTICLE_SETTINGS.TITLE') }}
      </h3>
      <div class="form-wrap">
        <label
          class="text-md my-4 py-2 leading-3 font-medium text-black-900 dark:text-slate-200"
        >
          {{ titleVisibility }}
          <switches
            v-model="visibility"
            theme="bootstrap"
            color="primary"
            class="text=md"
            :text-enabled="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.PUBLIC.HELP_TEXT_ENABLED')
            "
            :text-disabled="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.PUBLIC.HELP_TEXT_DISABLED')
            "
          />
        </label>
        <label>
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.CATEGORY.LABEL') }}
          <multiselect-dropdown
            class="custom-multiselect"
            :options="categories"
            :selected-item="selectedCategory"
            :has-thumbnail="false"
            :multiselector-title="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.CATEGORY.TITLE')
            "
            :multiselector-placeholder="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.CATEGORY.PLACEHOLDER')
            "
            :no-search-result="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.CATEGORY.NO_RESULT')
            "
            :input-placeholder="
              $t(
                'HELP_CENTER.ARTICLE_SETTINGS.FORM.CATEGORY.SEARCH_PLACEHOLDER'
              )
            "
            @click="onClickSelectCategory"
          />
        </label>
        <label>
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.AUTHOR.LABEL') }}
          <multiselect-dropdown
            :options="agents"
            :selected-item="assignedAuthor"
            :multiselector-title="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.AUTHOR.TITLE')
            "
            :multiselector-placeholder="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.AUTHOR.PLACEHOLDER')
            "
            :no-search-result="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.AUTHOR.NO_RESULT')
            "
            :input-placeholder="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.AUTHOR.SEARCH_PLACEHOLDER')
            "
            @click="onClickAssignAuthor"
          />
        </label>
        <label>
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.META_TITLE.LABEL') }}
          <textarea
            v-model="metaTitle"
            rows="3"
            type="text"
            :placeholder="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.META_TITLE.PLACEHOLDER')
            "
            @input="onChangeMetaInput"
          />
        </label>
        <label>
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.META_DESCRIPTION.LABEL') }}
          <textarea
            v-model="metaDescription"
            class="custom-multiselect"
            rows="3"
            type="text"
            :placeholder="
              $t(
                'HELP_CENTER.ARTICLE_SETTINGS.FORM.META_DESCRIPTION.PLACEHOLDER'
              )
            "
            @input="onChangeMetaInput"
          />
        </label>
        <label>
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.META_TAGS.LABEL') }}
          <multiselect
            ref="tagInput"
            v-model="metaTags"
            class="custom-multiselect"
            :placeholder="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.META_TAGS.PLACEHOLDER')
            "
            label="name"
            :options="metaOptions"
            track-by="name"
            :multiple="true"
            :taggable="true"
            :close-on-select="false"
            @search-change="handleSearchChange"
            @close="onBlur"
            @tag="addTagValue"
            @remove="removeTag"
          />
        </label>
        <label v-if="!visibility" class="mt-4">
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.TEAMS.LABEL') }}
          <multiselect
            v-model="selectedTeams"
            :multiple="true"
            :options="teams"
            track-by="id"
            label="name"
            :placeholder="
              $t('HELP_CENTER.ARTICLE_SETTINGS.FORM.TEAMS.SEARCH_PLACEHOLDER')
            "
            :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
            :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
          />
        </label>
      </div>
      <div class="action-buttons">
        <woot-button
          icon="archive"
          size="small"
          variant="clear"
          color-scheme="secondary"
          @click="onClickArchiveArticle"
        >
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.BUTTONS.ARCHIVE') }}
        </woot-button>
        <woot-button
          icon="delete"
          size="small"
          variant="clear"
          color-scheme="alert"
          @click="onClickDeleteArticle"
        >
          {{ $t('HELP_CENTER.ARTICLE_SETTINGS.BUTTONS.DELETE') }}
        </woot-button>
      </div>
    </div>
  </transition>
</template>

<script>
import Switches from 'vue-switches';
import MultiselectDropdown from 'shared/components/ui/MultiselectDropdown.vue';
import { mapGetters } from 'vuex';
import { debounce } from '@chatwoot/utils';
import { isEmptyObject } from 'dashboard/helper/commons.js';
export default {
  components: {
    MultiselectDropdown,
    Switches,
  },
  props: {
    article: {
      type: Object,
      default: () => ({}),
    },
  },
  data() {
    return {
      metaTitle: '',
      metaDescription: '',
      metaTags: [],
      metaOptions: [],
      tagInputValue: '',
    };
  },
  computed: {
    ...mapGetters({
      categories: 'categories/allCategories',
      agents: 'agents/getAgents',
      teams: 'teams/getTeams',
    }),
    titleVisibility() {
      return this.visibility
        ? this.$t('HELP_CENTER.ARTICLE_SETTINGS.FORM.PUBLIC.LABEL_ENABLED')
        : this.$t('HELP_CENTER.ARTICLE_SETTINGS.FORM.PUBLIC.LABEL_DISABLED');
    },
    assignedAuthor() {
      return this.article?.author;
    },
    selectedCategory() {
      return this.article?.category;
    },
    selectedTeams: {
      get() {
        return this.article?.teams;
      },
      set(value) {
        this.$emit('save-article', { teams: value });
      },
      deep: true,
      immediate: true,
    },
    visibility: {
      get() {
        return this.article?.visibility === 'public';
      },
      set(value) {
        this.$emit('save-article', {
          visibility: value ? 'public' : 'private',
        });
      },
      deep: true,
      immediate: true,
    },
    allTags() {
      return this.metaTags.map(item => item.name);
    },
  },
  watch: {
    article: {
      handler() {
        if (!isEmptyObject(this.article.meta || {})) {
          const {
            meta: { title = '', description = '', tags = [] },
          } = this.article;
          this.metaTitle = title;
          this.metaDescription = description;
          this.metaTags = this.formattedTags({ tags });
        }
      },
      deep: true,
      immediate: true,
    },
  },
  mounted() {
    this.saveArticle = debounce(
      () => {
        this.$emit('save-article', {
          meta: {
            title: this.metaTitle,
            description: this.metaDescription,
            tags: this.allTags,
          },
        });
      },
      1000,
      false
    );
  },
  methods: {
    formattedTags({ tags }) {
      return tags.map(tag => ({
        name: tag,
      }));
    },
    addTagValue(tagValue) {
      const tags = tagValue
        .split(',')
        .map(tag => tag.trim())
        .filter(tag => tag && !this.allTags.includes(tag));

      this.metaTags.push(...this.formattedTags({ tags: [...new Set(tags)] }));
      this.saveArticle();
    },
    removeTag() {
      this.saveArticle();
    },
    handleSearchChange(value) {
      this.tagInputValue = value;
    },
    onBlur() {
      if (this.tagInputValue) {
        this.addTagValue(this.tagInputValue);
      }
    },
    onClickSelectCategory({ id }) {
      this.$emit('save-article', { category_id: id });
    },
    onClickAssignAuthor({ id }) {
      this.$emit('save-article', { author_id: id });
      this.updateMeta();
    },
    onChangeMetaInput() {
      this.saveArticle();
    },
    onClickArchiveArticle() {
      this.$emit('archive-article');
      this.updateMeta();
    },
    onClickDeleteArticle() {
      this.$emit('delete-article');
      this.updateMeta();
    },
    updateMeta() {
      this.$emit('update-meta');
    },
  },
};
</script>

<style lang="scss" scoped>
.article-settings--container {
  @apply flex-[0.3] min-w-[15rem] max-w-[22.5rem] py-2 pl-4 rtl:pl-0 rtl:pr-4 ml-4 rtl:ml-0 rtl:mr-4 overflow-y-auto border-l rtl:border-r rtl:border-l-0 border-solid border-slate-50 dark:border-slate-700;

  .form-wrap {
    @apply mt-4 mb-6;

    textarea {
      @apply text-sm;
    }
  }

  .action-buttons {
    @apply flex flex-col;
  }
}
::v-deep .custom-multiselect {
  .multiselect {
    @apply mb-0;
  }
  .multiselect__content-wrapper {
    @apply hidden;
  }
  .multiselect--active .multiselect__tags {
    padding-right: var(--space-small) !important;
    @apply rounded-md;
  }
  .multiselect__placeholder {
    @apply text-slate-300 dark:text-slate-200 pt-2 mb-0;
  }
  .multiselect__select {
    @apply hidden;
  }
}
</style>
