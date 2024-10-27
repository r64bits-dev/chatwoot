<template>
  <div class="flex-1 overflow-auto p-4">
    <p>File Imports</p>
    <form @submit.prevent="uploadFile">
      <input type="file" @change="handleFileChange" />
      <woot-button type="submit" color-scheme="primary">Upload</woot-button>
    </form>
  </div>
</template>

<script>
export default {
  name: 'FileImports',
  data() {
    return {
      selectedFile: null,
    };
  },
  methods: {
    handleFileChange(event) {
      this.selectedFile = event.target.files[0];
    },
    async uploadFile() {
      if (!this.selectedFile) {
        alert('Please select a file first.');
        return;
      }

      const formData = new FormData();
      formData.append('file', this.selectedFile);

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
        alert('File uploaded successfully');
      } catch (error) {
        alert('Error uploading file');
      }
    },
  },
};
</script>

<style scoped>
/* Add any styles you need here */
</style>
