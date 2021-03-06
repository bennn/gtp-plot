#lang scribble/manual

@require[
  gtp-plot/reticulated-info
  gtp-plot/typed-racket-info
  scribble/example
  (for-label
    gtp-plot/configuration-info
    gtp-plot/performance-info
    gtp-plot/reticulated-info
    gtp-plot/sample-info
    gtp-plot/typed-racket-info
    gtp-plot/util
    racket/base
    racket/contract
    (only-in racket/math natural?))]

@(define tr-info-eval (make-base-eval '(require gtp-plot/typed-racket-info)))
@(define retic-info-eval (make-base-eval '(require gtp-plot/reticulated-info)))

@; -----------------------------------------------------------------------------
@title[#:tag "data-formats"]{Data Formats}

@section[#:tag "gtp-typed-racket-info"]{Typed Racket Info}
@defmodule[gtp-plot/typed-racket-info]

@defproc[(typed-racket-data? [ps path-string?]) boolean?]{
  A Typed Racket dataset:
  @itemlist[
  @item{
    lives in a file named @filepath{NAME-vX-OTHER.rktd},
     where @filepath{NAME} is the name of the program
     and @filepath{vX} is a Racket version number,
     and @filepath{OTHER} is any string (used to distinguish this data from other data with the same prefix).

    @bold{or} lives in a file with any name where the first non-whitespace
     characters on the first non-blank-line, non-comment
     line are the @litchar{#(} characters.

    @bold{or} lives in a @hyperlink["https://github.com/bennn/gtp-measure"]{@tt{#lang gtp-measure/output/typed-untyped}} file.

  }
  @item{
    contains (or is) a Racket vector with @racket[(expt 2 _N)] elements (for some natural @racket[_N]);
     entries in the vector are lists of runtimes.

    @bold{or} contains valid @hyperlink["https://github.com/bennn/gtp-measure"]{@tt{#lang gtp-measure/output/typed-untyped}} data.
  }]

  @history[
    #:changed "0.5" @elem{Accept vector}
    #:changed "0.4" @elem{Accept @tt{gtp-measure} output.}]

  Example data:
  @nested[#:style 'code-inset @verbatim{
    ;; Example Typed Racket GTP dataset
    #((1328)
    (42)
    (8) (1))
  }]
}

@defproc[(make-typed-racket-info [ps typed-racket-data?] [#:name name (or/c #f symbol?) #f]) typed-racket-info?]{
  Build a @tech{performance info} structure from a Typed Racket dataset.
}

@defproc[(typed-racket-info? [x any/c]) boolean?]{
  Predicate for Typed Racket datasets.
}

@defproc[(typed-racket-id? [x any/c]) boolean?]{
  Predicate for a Typed Racket configuration name.
  A name is a @racket[_k]-character string of @racket[#\0] and @racket[#\1] characters.
  Each digit represents one unit, which may or may not be typed.
  A @racket[#\1] means @emph{typed} and a @racket[#\0] means @emph{untyped}.

  @examples[#:eval tr-info-eval
    (typed-racket-id? "0000")
    (typed-racket-id? "001000011")
    (typed-racket-id? "2001")
    (typed-racket-id? 10)
  ]
}

@defproc[(typed-racket-id<=? [id0 typed-racket-id?] [id1 typed-racket-id?]) boolean?]{
  Returns true if the first id describes a subset of the types in the second id.

  @examples[#:eval tr-info-eval
    (typed-racket-id<=? "0000" "1111")
    (typed-racket-id<=? "1111" "0000")
    (typed-racket-id<=? "0110" "1110")
    (typed-racket-id<=? "0110" "1011")
  ]

  @history[#:added "0.6"]
}

@defproc[(make-typed-racket-sample-info [src (listof typed-racket-info?)]
                                        [#:name name symbol?]
                                        [#:typed-configuration tc typed-configuration-info?]
                                        [#:untyped-configuration uc untyped-configuration-info?]) sample-info?]{
  Make a @racket[sample-info?] structure for a Typed Racket program,
   given a list of data files for the program (@racket[src]),
   a name for the program @racket[name],
   and data for the program's typed and untyped configurations.
}

@defproc[(make-typed-racket-configuration-info [id typed-racket-id?] [time* (listof nonnegative-real/c)]) typed-racket-configuration-info?]{
  Constructor for a Typed Racket configuration.
}

@defproc[(typed-racket-configuration-info? [x any/c]) boolean?]{
  Predicate for a Typed Racket configuration.
}

@defproc[(typed-configuration-info? [x any/c]) boolean?]{
  Predicate for a fully-typed Typed Racket configuration.
}

@defproc[(untyped-configuration-info? [x any/c]) boolean?]{
  Predicate for an untyped Typed Racket configuration.
}

@defproc[(typed-racket-info%best-typed-path [pi typed-racket-info?] [n natural?]) typed-racket-info?]{
  Return a structure with the same configurations as @racket[pi], but
   each configuration has the best-possible runtimes that can be reached
   after @racket[n] type conversion steps.

  @history[#:added "0.6"]
}


@section[#:tag "gtp-reticulated-info"]{Reticulated Info}
@defmodule[gtp-plot/reticulated-info]

@defproc[(reticulated-data? [ps path-string?]) boolean?]{
  A Reticulated dataset is a path to a directory. The directory:
  @itemlist[
  @item{
    has a name like @filepath{NAME-OTHER},
     where @filepath{NAME} is the name of the program
     and @filepath{OTHER} is any string (used to distinguish from other data with the same prefix);
  }
  @item{
    contains a file named @filepath{NAME-python.tab},
     where each line has a floating point number;
  }
  @item{
    either:
    @itemlist[
    @item{
      contains a @tech{Reticulated data file} named @filepath{NAME.tab};
    }
    @item{
      or a compressed @tech{Reticulated data file} named @filepath{NAME.tab.gz};
    }
    @item{
      or
       a @tech{Reticulated meta file} @filepath{NAME-meta.rktd},
       a @tech[#:key "reticulated-data-file"]{data file} @filepath{NAME-retic-typed.tab},
       a @tech[#:key "reticulated-data-file"]{data file} @filepath{NAME-retic-untyped.tab},
       and a sequence of files named @filepath{sample-NUM.tab} (where @filepath{NUM} is a sequence of digits).
    }
    ]
  }
  ]

  A @deftech{Reticulated data file} describes the running time of configurations.
  Each line in a data file has the format:
  @nested[#:style 'code-inset @verbatim{
    ID	NUM-TYPES	[TIME, ...]
  }]
  where:
  @itemlist[
  @item{
    @margin-note{Wikipedia: @hyperlink["https://en.wikipedia.org/wiki/Mixed_radix"]{mixed-radix number}}
    @tt{ID} is a hyphen-separated sequence of digits.
    These represent a configuration as a @emph{mixed-radix number};
     the radix of position @math{k} is the number of @tech{typeable components}
     in module @math{k} of the program.
  }
  @item{
    @tt{NUM-TYPES} is a natural number, and
  }
  @item{
    @tt{TIME} is a positive floating-point number.
  }
  ]

  Two lines from an example @tech{Reticulated data file}:
  @nested[#:style 'code-inset @verbatim{
    13-0-2-7-7	9	[2.096725507, 2.134529453, 2.088266101, 2.1067140589999998, ]
    0-1-18-7-3	11	[2.153331553, 2.217980131, 2.0789024329999997, 2.1293707979999996, ]
  }]

  A @deftech{Reticulated meta file} states the number of type annotations in
   a sampled program via a Racket hash.
  Example meta file:
  @nested[#:style 'code-inset @verbatim{
    #hash((num-units . 19))
  }]

  Sorry for the complex format, it's strongly motivated by the data in the
   @tt{gm-pepm-2018} package.
}

@defproc[(make-reticulated-info [ps reticulated-data?] [kind (or/c 'exhaustive 'approximate #f) #f]) reticulated-info?]{
  Build a @tech{performance info} structure from a Reticulated dataset.

  By default, inspects the given dataset and chooses whether to return
   a @racket[reticulated-info?] struct with exhaustive data
   or a @racket[sample-info?] struct with approximate data.
  Use the @racket[kind] argument to override the default.
}

@defproc[(reticulated-info? [x any/c]) boolean?]{
  Predicate for Reticulated datasets.
}

@defproc[(reticulated-id? [x any/c]) boolean?]{
  Predicate for a Reticulated configuration name.
  A name is a sequence of base-10 numbers.
  Each position in the sequence corresponds to a module.
  Each number encodes the type annotations in the module.

  Configuration names may be strings of hypen-separated numbers or lists
   of natural numbers.

  @examples[#:eval retic-info-eval
    (reticulated-id? "0")
    (reticulated-id? "0-0-0")
    (reticulated-id? "2001-14-3")
    (reticulated-id? '(2001 14 3))
  ]

  To decode the type annotations from one number @racket[_N],
   convert @racket[_N] to base-2 and look for @racket[#\0] digits.
  Each place in a binary number correponds to a typed unit,
   each @racket[#\0] means the unit is typed,
   and each @racket[#\1] means the unit in untyped.

  Be advised, the interpretations of @racket[#\0] and @racket[#\1] are the
   opposite of what @racket[typed-racket-id?] does.
}

@defproc[(reticulated-id<=? [id0 reticulated-id?] [id1 reticulated-id?]) boolean?]{
  Returns true if the first configuration name describes a subset of the
   type annotations in the second name.

  @examples[#:eval retic-info-eval
    (reticulated-id<=? "1" "0")
    (reticulated-id<=? "0" "1")
    (reticulated-id<=? "7-6" "5-6")
    (reticulated-id<=? "6-6" "5-6")
  ]

  The input configurations must be for the same benchmark.

  @history[#:added "0.6"]
}

@defproc[(reticulated-info%best-typed-path [pi reticulated-info?] [n natural?]) reticulated-info?]{
  Return a structure with the same configurations as @racket[pi], but
   each configuration has the best-possible runtimes that can be reached
   after @racket[n] type conversion steps.

  @history[#:added "0.6"]
}

