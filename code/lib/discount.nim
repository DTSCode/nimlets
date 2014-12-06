import unsigned

type
  Document* = pointer
const
  mkdNoLinks*         = 1u32 shl 1u32
  mkdNoImage*         = 1u32 shl 2u32
  mkdNoPants*         = 1u32 shl 3u32
  mkdNoGtml*          = 1u32 shl 4u32
  mkdStrict*          = 1u32 shl 5u32
  mkdTagText*         = 1u32 shl 6u32
  mkdNoExt*           = 1u32 shl 7u32
  mkdCdata*           = 1u32 shl 8u32
  mkdNoSuperscript*   = 1u32 shl 9u32
  mkdNoRelaxed*       = 1u32 shl 10u32
  mkdNoTables*        = 1u32 shl 11u32
  mkdNostrikethrough* = 1u32 shl 12u32
  mkdToc*             = 1u32 shl 13u32
  mkdCompat*          = 1u32 shl 14u32
  mkdAutoLink*        = 1u32 shl 15u32
  mkdSafeLink*        = 1u32 shl 16u32
  mkdNoHeader*        = 1u32 shl 17u32
  mkdTabstop*         = 1u32 shl 18u32
  mkdNoDivQuote*      = 1u32 shl 19u32
  mkdNoAlphaList*     = 1u32 shl 20u32
  mkdNoDList*         = 1u32 shl 21u32
  mkdExtraFootnote*   = 1u32 shl 22u32
  mkdNoStyle*         = 1u32 shl 23u32

{.push importc, cdecl.}
proc mkd_compile*      ( a2: Document, a3: uint32                             ) : cint
proc mkd_document*     ( a2: Document, a3: ptr cstring                        ) : cint
proc mkd_generatehtml* ( a2: Document, a3: File                               ) : cint
proc mkd_css*          ( a2: Document, a3: ptr cstring                        ) : cint
proc mkd_generatecss*  ( a2: Document, a3: File                               ) : cint
proc mkd_xml*          ( a2: cstring,  a3: cint, a4: ptr cstring              ) : cint
proc mkd_generatexml*  ( a2: cstring,  a3: cint, a4: File                     ) : cint
proc mkd_cleanup*      ( a2: Document                                         )
proc mkd_line*         ( a2: cstring,  a3: cint, a4: ptr cstring,  a5: uint32 ) : cint
proc mkd_generateline* ( a2: cstring,  a3: cint, a4: File,         a5: uint32 ) : cint
proc mkd_basename*     ( a2: Document, a3: cstring                            )
proc mkd_in*           ( a2: File,     a3: uint32                             ) : Document
proc mkd_string*       ( a2: cstring,  a3: cint, a4: uint32                   ) : Document
proc mkd_ref_prefix*   ( a2: Document, a3: cstring                            )
proc gfm_in*           ( a2: File,     a3: uint32                             ) : Document
proc gfm_string*       ( a2: cstring,  a3: cint, a4: uint32                   ) : Document
{.pop.}
{.link: "lib/discount/libmarkdown.a".}

proc open_memstring*(buf: ptr cstring, size: ptr csize): File {.importc, header: "stdio.h"}

let
  mkd_style* = mkd_generatecss
  mkd_text*  = mkd_generateline
