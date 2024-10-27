<template>
  <div class="flex-1 overflow-auto p-4">
    <form @submit.prevent="uploadFile">
      <woot-input-file @files-selected="handleFilesSelected" />
    </form>
  </div>
</template>

<script>
export default {
  name: 'FileImports',
  data() {
    return {
      selectedFiles: [],
    };
  },
  methods: {
    handleFilesSelected(files) {
      this.selectedFiles = files;
    },
    async uploadFile() {
      if (this.selectedFiles.length === 0) {
        bus.$emit('newToastMessage', 'Por favor, selecione um arquivo.');
        return;
      }

      const formData = new FormData();
      this.selectedFiles.forEach((file, index) => {
        formData.append(`file${index}`, file); // Adiciona cada arquivo
      });

      try {
        const response = await fetch('/api/upload', {
          method: 'POST',
          body: formData,
        });

        if (!response.ok) {
          throw new Error('File upload failed');
        }

        const result = await response.json();
        // eslint-disable-next-line no-console
        console.log(result);
        bus.$emit('newToastMessage', 'Arquivos enviados com sucesso');
      } catch (error) {
        bus.$emit('newToastMessage', 'Erro ao enviar arquivo');
      }
    },
  },
};
</script>

<style scoped>
/* Add any styles you need here */
</style>
