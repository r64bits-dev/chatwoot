<template>
  <div class="file-upload">
    <label v-if="label" class="file-upload__label">{{ label }}</label>
    <div
      class="file-dropzone"
      @click="triggerFileSelect"
      @dragover.prevent
      @dragenter.prevent
      @drop.prevent="handleDrop"
    >
      <input
        ref="fileInput"
        type="file"
        accept=".csv"
        :multiple="multiple"
        class="file-input"
        @change="handleFileSelect"
      />
      <button class="button--upload">
        {{ buttonText }}
      </button>
      <p>Arraste e solte arquivos ou clique para selecionar</p>
    </div>
    <ul v-if="files.length" class="file-list">
      <li v-for="(file, index) in files" :key="index" class="file-list__item">
        <span>{{ file.name }}</span>
        <button @click="removeFile(index)">Remover</button>
      </li>
    </ul>
    <span v-if="error" class="error-message">{{ error }}</span>
  </div>
</template>

<script>
export default {
  name: 'WootFileInput',
  props: {
    label: {
      type: String,
      default: 'Upload de Arquivo',
    },
    buttonText: {
      type: String,
      default: 'Selecionar Arquivos',
    },
    multiple: {
      type: Boolean,
      default: true,
    },
    error: {
      type: String,
      default: '',
    },
  },
  data() {
    return {
      files: [],
      errorMessage: '',
    };
  },
  methods: {
    triggerFileSelect() {
      this.$refs.fileInput.click();
    },
    handleFileSelect(event) {
      this.addFiles(event.target.files);
      this.$refs.fileInput.value = null;
    },
    handleDrop(event) {
      this.addFiles(event.dataTransfer.files);
    },
    addFiles(fileList) {
      Array.from(fileList).forEach(file => {
        if (file.name.endsWith('.csv')) {
          this.files.push(file);
          this.errorMessage = ''; // Limpa mensagem de erro
        } else {
          this.errorMessage = `Arquivo inválido: ${file.name}. Apenas arquivos .csv são permitidos.`;
        }
      });
      this.$emit('files-selected', this.files);
    },
    removeFile(index) {
      this.files.splice(index, 1);
      this.$emit('files-selected', this.files);
    },
  },
};
</script>

<style scoped lang="scss">
.file-upload {
  display: flex;
  flex-direction: column;
  gap: 8px;

  .file-dropzone {
    border: 2px dashed #ccc;
    padding: 16px;
    text-align: center;
    cursor: pointer;
    transition: border-color 0.3s;
    position: relative;
  }

  .file-dropzone:hover {
    border-color: #999;
  }

  .file-input {
    display: none;
  }

  .file-list {
    list-style: none;
    padding: 0;
    margin: 0;

    .file-list__item {
      display: flex;
      justify-content: space-between;
      margin-bottom: 4px;
    }
  }

  .error-message {
    color: red;
    font-size: 0.875rem;
  }
}
</style>
