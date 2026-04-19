#!/bin/bash

# =========================
# Script para flujo de simulación
# =========================

set -e  # detener si hay error

echo "➡️ Entrando a carpeta arqui..."
cd arqui || { echo "❌ No existe la carpeta 'arqui'"; exit 1; }

echo "🔧 Ejecutando simulación..."
make run

echo "📊 Abriendo visor de ondas..."
make wave

echo "🧹 Limpiando archivos..."
make clean

echo "✅ Flujo completado"