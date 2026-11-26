export function formatCurrency(value) {
  const sign = value < 0 ? '-' : ''
  const formatted = Math.abs(value).toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  return `${sign}R$\u00A0${formatted}`
}
