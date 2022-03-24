sources = [
    'dev',
    'gs',
    'img',
    'res',
    'stylesheets',
    'index.md'
]

foreach src : sources
    links += custom_target(
        'link-@0@'.format(src),
        output: src,
        command: [
            'ln',
            '--force',
            '--symbolic',
            meson.current_source_dir() / src,
            '@OUTPUT@',
        ]
    )
endforeach

if apis.length() > 0
    subdir('api')
endif
