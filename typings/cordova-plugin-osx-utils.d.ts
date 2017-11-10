interface Navigator {
    readonly app: {
        exitApp(): void
        openUrl(url: string, success?: () => void, fail?: (err: { code: number, message: string }) => void): void

        resize(fullscreen: true, success?: () => void): void
        resize(fullscreen: false,
            rect: {
                x?: number,
                y?: number,
                width?: number,
                height?: number
            },
            flags?: {
                minimize?: boolean,
                maximize?: boolean,
                close?: boolean,
                resize?: boolean
                border?: boolean
            },
            success?: () => void,
            fail?: (err: { code: number, message: string }) => void): void
    }
}