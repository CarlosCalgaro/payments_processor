import * as React from "react"

export const ArrowLeft = React.forwardRef<
  SVGSVGElement,
  React.SVGProps<SVGSVGElement>
>(({ ...props }, ref) => (
  <svg
    ref={ref}
    xmlns="http://www.w3.org/2000/svg"
    width="24"
    height="24"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
    {...props}
  >
    <path d="M19 12H5M12 19l-7-7 7-7" />
  </svg>
))
ArrowLeft.displayName = "ArrowLeft"

export { ArrowLeft as default }
