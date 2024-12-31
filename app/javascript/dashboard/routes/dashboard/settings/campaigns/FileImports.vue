<template>
  <div class="flex-1 overflow-auto p-4">
    <form @submit.prevent="uploadFile">
      <woot-input-file @files-selected="handleFilesSelected" />

      <div class="flex justify-end mt-3">
        <woot-button
          variant="smooth"
          color-scheme="primary"
          icon="file-upload"
          @click="uploadFile"
        >
          {{ $t('FIlE_IMPORT.SUBMIT') }}
        </woot-button>
      </div>
    </form>

    <!-- Mostrar os arquivos já importados -->
    <woot-card
      class="mt-3"
      header="Arquivos Importados"
      sub-header="Aqui estão os arquivos importados"
      :header-status="{
        status: 'success',
        message: 'Todos os arquivos foram importados',
      }"
    >
      <template #body>
        <woot-list :items="selectedFiles">
          <template #item="{ item }">
            <!-- Nome do arquivo e tamanho -->
            <div class="flex items-center">
              <fluent-icon icon="file-upload" class="default-icon" />
              <span class="file-name flex-1">{{ item.name }}</span>
              <span class="file-size text-gray-500 ml-2"
                >{{ (item.size / 1024).toFixed(2) }} KB</span
              >
              <button
                class="delete-button text-red-500 ml-4"
                @click="removeFile(item.id)"
              >
                Remover
              </button>
            </div>
          </template>
        </woot-list>
      </template>
    </woot-card>
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
      // eslint-disable-next-line no-console
      console.log(files);
      this.selectedFiles = files.map(file => ({
        id: file.id,
        name: file.name,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified,
      }));
    },
    removeFile(fileId) {
      this.selectedFiles = this.selectedFiles.filter(
        file => file.id !== fileId
      );
      bus.$emit('newToastMessage', 'Arquivo removido');
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

<style scoped lang="scss"></style>
