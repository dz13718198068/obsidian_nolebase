---
layout: page
sidebar: false
---

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vitepress'

const router = useRouter()

onMounted(() => {
  // 自动跳转到笔记首页
  router.replace('/笔记/index')
})
</script>

# 正在进入小千FPGA笔记...
未自动跳转请点击 → [笔记页面](/笔记/index)