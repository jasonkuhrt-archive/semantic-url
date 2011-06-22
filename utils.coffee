module.exports =
    
    chunkURL: (raw_url)->
        url_sans_end_slashes = raw_url.replace(/^\s*\/|\/\s*$/g,'')
        if url_sans_end_slashes
            url_sans_end_slashes.split '/'
        else
            []

    unslugify: (slug)->
        slug.replace /-/g,' '

    slugify: (str)->
        str.replace(/\s/g,'-').toLowerCase().replace(/[^-\w]/g,'')

    handlify: (str)->
        str.replace(/\s/g,'_').toLowerCase().replace(/[^-\w]/g,'')
