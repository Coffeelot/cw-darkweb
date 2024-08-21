<template>
  <div class="infotext">
    <h1>{{ props.title }}</h1>
    <h3 v-if="props.text">{{ props.text }}</h3>
  </div>
</template>

<script setup lang="ts">

const props = defineProps<{
  title: string,
  text?: string
}>();
</script>

<style scoped lang="scss">
.infotext {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
</style>
