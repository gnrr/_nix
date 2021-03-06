;;; allout.el --- Extensive allout mode for use alone and with other modes.

;; Copyright (C) 1992, 1993, 1994 Free Software Foundation, Inc.

;; Author: Ken Manheimer <klm@python.org>
;; Maintainer: Ken Manheimer <klm@python.org>
;; Created: Dec 1991 - first release to usenet
;; Version: Id: allout.el,v 4.3 1994/05/12 17:43:08 klm Exp ||
;; Keywords: outlines

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;;_* Commentary:

;; Allout allout mode provides extensive allout formatting and
;; manipulation capabilities, subsuming and well beyond that of
;; standard emacs allout mode.  It is specifically aimed at
;; supporting allout structuring and manipulation of syntax-
;; sensitive text, eg programming languages.  (For an example, see the
;; allout code itself, which is organized in allout structure.)
;;
;; It also includes such things as topic-oriented repositioning, cut, and
;; paste; integral allout exposure-layout; incremental search with
;; dynamic exposure/concealment of concealed text; automatic topic-number
;; maintenance; and many other features.
;;
;; See the docstring of the variables `allout-layout' and
;; `allout-auto-activation' for details on automatic activation of
;; allout allout-mode as a minor mode.  (It has changed since allout
;; 3.x, for those of you that depend on the old method.)
;;
;; Note - the lines beginning with `;;;_' are allout topic headers.
;;        Just `ESC-x eval-current-buffer' to give it a whirl.

;;Ken Manheimer	      				   301 975-3539
;;ken.manheimer@nist.gov			   FAX: 301 963-9137
;;
;;Computer Systems and Communications Division
;;
;;		Nat'l Institute of Standards and Technology
;;		Technology A151
;;		Gaithersburg, MD 20899

;;;_* Provide
(provide 'nallout)
;(provide 'allout)

;;;_* USER CUSTOMIZATION VARIABLES:
(defgroup allout nil
  "Extensive allout mode for use alone and with other modes."
  :prefix "allout-"
  :group 'outlines)

;;;_ + Layout, Mode, and Topic Header Configuration

;;;_  = allout-auto-activation
(defvar allout-auto-activation nil
  "*Regulates auto-activation modality of allout outlines - see `allout-init'.

Setq-default by `allout-init' to regulate whether or not allout
allout mode is automatically activated when the buffer-specific
variable `allout-layout' is non-nil, and whether or not the layout
dictated by `allout-layout' should be imposed on mode activation.

With value `t', auto-mode-activation and auto-layout are enabled.
\(This also depends on `allout-find-file-hooks' being installed in
`find-file-hooks', which is also done by `allout-init'.)

With value `ask', auto-mode-activation is enabled, and endorsement for
performing auto-layout is asked of the user each time.

With value `activate', only auto-mode-activation is enabled,
auto-layout is not.

With value `nil', neither auto-mode-activation nor auto-layout are
enabled.

See the docstring for `allout-init' for the proper interface to
this variable.")
;;;_  = allout-layout
(defvar allout-layout nil
  "*Layout specification and provisional mode trigger for allout outlines.

Buffer-specific.

A list value specifies a default layout for the current buffer, to be
applied upon activation of allout allout-mode.  Any non-nil value will
automatically trigger allout allout-mode, provided `allout-init'
has been called to enable it.

See the docstring for `allout-init' for details on setting up for
auto-mode-activation, and for `allout-expose-topic' for the format of
the layout specification.

You can associate a particular allout layout with a file by setting
this var via the file's local variables.  For example, the following
lines at the bottom of an Emacs Lisp file:

;;;Local variables:
;;;allout-layout: \(0 : -1 -1 0\)
;;;End:

will, modulo the above-mentioned conditions, cause the mode to be
activated when the file is visited, followed by the equivalent of
`\(allout-expose-topic 0 : -1 -1 0\)'.  \(This is the layout used for
the allout.el, itself.)

Also, allout's mode-specific provisions will make topic prefixes default
to the comment-start string, if any, of the language of the file.  This
is modulo the setting of `allout-use-mode-specific-leader', which see.")
(make-variable-buffer-local 'allout-layout)

;;;_  = allout-header-prefix
(defcustom allout-header-prefix "."
  "*Leading string which helps distinguish topic headers.

Allout topic header lines are identified by a leading topic
header prefix, which mostly have the value of this var at their front.
\(Level 1 topics are exceptions.  They consist of only a single
character, which is typically set to the allout-primary-bullet.  Many
outlines start at level 2 to avoid this discrepancy."
  :type 'string
  :group 'allout)
(make-variable-buffer-local 'allout-header-prefix)
;;;_  = allout-primary-bullet
(defcustom allout-primary-bullet "*"
  "Bullet used for top-level allout topics.

Allout topic header lines are identified by a leading topic header
prefix, which is concluded by bullets that includes the value of this
var and the respective allout-*-bullets-string vars.

The value of an asterisk (`*') provides for backwards compatibility
with the original emacs allout mode.  See allout-plain-bullets-string
and allout-distinctive-bullets-string for the range of available
bullets."
  :type 'string
  :group 'allout)
(make-variable-buffer-local 'allout-primary-bullet)
;;;_  = allout-plain-bullets-string
(defcustom allout-plain-bullets-string (concat allout-primary-bullet
					     "+-:.;,")
  "*The bullets normally used in allout topic prefixes.

See `allout-distinctive-bullets-string' for the other kind of
bullets.

DO NOT include the close-square-bracket, `]', as a bullet.

Allout mode has to be reactivated in order for changes to the value
of this var to take effect."
  :type 'string
  :group 'allout)
(make-variable-buffer-local 'allout-plain-bullets-string)
;;;_  = allout-distinctive-bullets-string
(defcustom allout-distinctive-bullets-string "=>([{}&!?#%\"X@$~\\"
  "*Persistent allout header bullets used to distinguish special topics.

These bullets are not offered among the regular, level-specific
rotation, and are not altered by automatic rebulleting, as when
shifting the level of a topic.  See `allout-plain-bullets-string' for
the selection of alternating bullets.

You must run `set-allout-regexp' in order for changes
to the value of this var to effect allout-mode operation.

DO NOT include the close-square-bracket, `]', on either of the bullet
strings."
  :type 'string
  :group 'allout)
(make-variable-buffer-local 'allout-distinctive-bullets-string)

;;;_  = allout-use-mode-specific-leader
(defcustom allout-use-mode-specific-leader t
  "*When non-nil, use mode-specific topic-header prefixes.

Allout allout mode will use the mode-specific `allout-mode-leaders'
and/or comment-start string, if any, to lead the topic prefix string,
so topic headers look like comments in the programming language.

String values are used as they stand.

Value `t' means to first check for assoc value in `allout-mode-leaders'
alist, then use comment-start string, if any, then use default \(`.').
\(See note about use of comment-start strings, below.\)

Set to the symbol for either of `allout-mode-leaders' or
`comment-start' to use only one of them, respectively.

Value `nil' means to always use the default \(`.'\).

comment-start strings that do not end in spaces are tripled, and an
`_' underscore is tacked on the end, to distinguish them from regular
comment strings.  comment-start strings that do end in spaces are not
tripled, but an underscore is substituted for the space.  [This
presumes that the space is for appearance, not comment syntax.  You
can use `allout-mode-leaders' to override this behavior, when
incorrect.]"
  :type '(choice (const t) (const nil) string 
		 (const allout-mode-leaders)
		 (const comment-start))
  :group 'allout)
;;;_  = allout-mode-leaders
(defvar allout-mode-leaders '()
  "Specific allout-prefix leading strings per major modes.

Entries will be used in the stead (or lieu) of mode-specific
comment-start strings.  See also `allout-use-mode-specific-leader'.

If you're constructing a string that will comment-out allout
structuring so it can be included in program code, append an extra
character, like an \"_\" underscore, to distinguish the lead string
from regular comments that start at bol.")

;;;_  = allout-old-style-prefixes
(defcustom allout-old-style-prefixes nil
  "*When non-nil, use only old-and-crusty allout-mode `*' topic prefixes.

Non-nil restricts the topic creation and modification
functions to asterix-padded prefixes, so they look exactly
like the original emacs-allout style prefixes.

Whatever the setting of this variable, both old and new style prefixes
are always respected by the topic maneuvering functions."
  :type 'boolean
  :group 'allout)
(make-variable-buffer-local 'allout-old-style-prefixes)
;;;_  = allout-stylish-prefixes - alternating bullets
(defcustom allout-stylish-prefixes t
  "*Do fancy stuff with topic prefix bullets according to level, etc.

Non-nil enables topic creation, modification, and repositioning
functions to vary the topic bullet char (the char that marks the topic
depth) just preceding the start of the topic text) according to level.
Otherwise, only asterisks (`*') and distinctive bullets are used.

This is how an allout can look (but sans indentation) with stylish
prefixes:

    * Top level
    .* A topic
    . + One level 3 subtopic
    .  . One level 4 subtopic
    .  . A second 4 subtopic
    . + Another level 3 subtopic
    .  #1 A numbered level 4 subtopic
    .  #2 Another
    .  ! Another level 4 subtopic with a different distinctive bullet
    .  #4 And another numbered level 4 subtopic

This would be an allout with stylish prefixes inhibited (but the
numbered and other distinctive bullets retained):

    * Top level
    .* A topic
    . * One level 3 subtopic
    .  * One level 4 subtopic
    .  * A second 4 subtopic
    . * Another level 3 subtopic
    .  #1 A numbered level 4 subtopic
    .  #2 Another
    .  ! Another level 4 subtopic with a different distinctive bullet
    .  #4 And another numbered level 4 subtopic

Stylish and constant prefixes (as well as old-style prefixes) are
always respected by the topic maneuvering functions, regardless of
this variable setting.

The setting of this var is not relevant when allout-old-style-prefixes
is non-nil."
  :type 'boolean
  :group 'allout)
(make-variable-buffer-local 'allout-stylish-prefixes)

;;;_  = allout-numbered-bullet
(defcustom allout-numbered-bullet "#"
  "*String designating bullet of topics that have auto-numbering; nil for none.

Topics having this bullet have automatic maintenance of a sibling
sequence-number tacked on, just after the bullet.  Conventionally set
to \"#\", you can set it to a bullet of your choice.  A nil value
disables numbering maintenance."
  :type '(choice (const nil) string)
  :group 'allout)
(make-variable-buffer-local 'allout-numbered-bullet)
;;;_  = allout-file-xref-bullet
(defcustom allout-file-xref-bullet "@"
  "*Bullet signifying file cross-references, for `allout-resolve-xref'.

Set this var to the bullet you want to use for file cross-references.
Set it to nil if you want to inhibit this capability."
  :type '(choice (const nil) string)
  :group 'allout)

;;;_ + LaTeX formatting
;;;_  - allout-number-pages
(defcustom allout-number-pages nil
  "*Non-nil turns on page numbering for LaTeX formatting of an allout."
  :type 'boolean
  :group 'allout)
;;;_  - allout-label-style
(defcustom allout-label-style "\\large\\bf"
  "*Font and size of labels for LaTeX formatting of an allout."
  :type 'string
  :group 'allout)
;;;_  - allout-head-line-style
(defcustom allout-head-line-style "\\large\\sl "
  "*Font and size of entries for LaTeX formatting of an allout."
  :type 'string
  :group 'allout)
;;;_  - allout-body-line-style
(defcustom allout-body-line-style " "
  "*Font and size of entries for LaTeX formatting of an allout."
  :type 'string
  :group 'allout)
;;;_  - allout-title-style
(defcustom allout-title-style "\\Large\\bf"
  "*Font and size of titles for LaTeX formatting of an allout."
  :type 'string
  :group 'allout)
;;;_  - allout-title
(defcustom allout-title '(or buffer-file-name (current-buffer-name))
  "*Expression to be evaluated to determine the title for LaTeX
formatted copy."
  :type 'sexp
  :group 'allout)
;;;_  - allout-line-skip
(defcustom allout-line-skip ".05cm"
  "*Space between lines for LaTeX formatting of an allout."
  :type 'string
  :group 'allout)
;;;_  - allout-indent
(defcustom allout-indent ".3cm"
  "*LaTeX formatted depth-indent spacing."
  :type 'string
  :group 'allout)

;;;_ + Miscellaneous customization

;;;_  = allout-keybindings-list
;;; You have to reactivate allout-mode - `(allout-mode t)' - to
;;; institute changes to this var.
(defvar allout-keybindings-list ()
  "*List of allout-mode key / function bindings.

These bindings will be locally bound on the allout-mode-map.  The
keys will be prefixed by allout-command-prefix, unless the cell
contains a third, no-nil element, in which case the initial string
will be used as is.")
(setq allout-keybindings-list
      '(
                                        ; Motion commands:
        ("?t" allout-latexify-exposed)
        ("\C-n" allout-next-visible-heading)
        ("\C-p" allout-previous-visible-heading)
        ("\C-u" allout-up-current-level)
        ("\C-f" allout-forward-current-level)
        ("\C-b" allout-backward-current-level)
        ("\C-a" allout-beginning-of-current-entry)
        ("\C-e" allout-end-of-current-entry)
	;;("\C-n" allout-next-line-or-topic)
	;;("\C-p" allout-previous-line-or-topic)
                                        ; Exposure commands:
        ("\C-i" allout-show-children)
        ("\C-s" allout-show-current-subtree)
        ("\C-h" allout-hide-current-subtree)
        ("\C-o" allout-show-current-entry)
        ("!" allout-show-all)
                                        ; Alteration commands:
        (" " allout-open-sibtopic)
        ("." allout-open-subtopic)
        ("," allout-open-supertopic)
        ("'" allout-shift-in)
        (">" allout-shift-in)
        ("<" allout-shift-out)
        ("\C-m" allout-rebullet-topic)
        ("*" allout-rebullet-current-heading)
        ("#" allout-number-siblings)
        ("\C-k" allout-kill-line t)
        ("\C-y" allout-yank t)
        ("\M-y" allout-yank-pop t)
        ("\C-k" allout-kill-topic)
                                        ; Miscellaneous commands:
	("\C-@" allout-mark-topic)
        ("@" allout-resolve-xref)
        ("?c" allout-copy-exposed)))

;;;_  = allout-command-prefix
(defcustom allout-command-prefix "\C-c"
  "*Key sequence to be used as prefix for allout mode command key bindings."
  :type 'string
  :group 'allout)

;;;_  = allout-enwrap-isearch-mode
(defcustom allout-enwrap-isearch-mode t
  "*Set non-nil to enable automatic exposure of concealed isearch targets.

If non-nil, isearch will expose hidden text encountered in the course
of a search, and to reconceal it if the search is continued past it."
  :type 'boolean
  :group 'allout)

;;;_  = allout-use-hanging-indents
(defcustom allout-use-hanging-indents t
  "*If non-nil, topic body text auto-indent defaults to indent of the header.
Ie, it is indented to be just past the header prefix.  This is
relevant mostly for use with indented-text-mode, or other situations
where auto-fill occurs.

\[This feature no longer depends in any way on the `filladapt.el'
lisp-archive package.\]"
  :type 'boolean
  :group 'allout)
(make-variable-buffer-local 'allout-use-hanging-indents)

;;;_  = allout-reindent-bodies
(defcustom allout-reindent-bodies (if allout-use-hanging-indents
				    'text)
  "*Non-nil enables auto-adjust of topic body hanging indent with depth shifts.

When active, topic body lines that are indented even with or beyond
their topic header are reindented to correspond with depth shifts of
the header.

A value of `t' enables reindent in non-programming-code buffers, ie
those that do not have the variable `comment-start' set.  A value of
`force' enables reindent whether or not `comment-start' is set."
  :type '(choice (const nil) (const t) (const text) (const force))
  :group 'allout)

(make-variable-buffer-local 'allout-reindent-bodies)

;;;_  = allout-inhibit-protection
(defcustom allout-inhibit-protection nil
  "*Non-nil disables warnings and confirmation-checks for concealed-text edits.

Allout mode uses emacs change-triggered functions to detect unruly
changes to concealed regions.  Set this var non-nil to disable the
protection, potentially increasing text-entry responsiveness a bit.

This var takes effect at allout-mode activation, so you may have to
deactivate and then reactivate the mode if you want to toggle the
behavior."
  :type 'boolean
  :group 'allout)

;;;_* CODE - no user customizations below.

;;;_ #1  Internal Allout Formatting and Configuration
;;;_  - Version
;;;_   = allout-version
(defvar allout-version
  (let ((rcs-rev "Revision: 4.3"))
    (condition-case err
	(save-match-data
	  (string-match "Revision: \\([0-9]+\\.[0-9]+\\)" rcs-rev)
	  (substring rcs-rev (match-beginning 1) (match-end 1)))
      (error rcs-rev)))
  "Revision number of currently loaded allout package.  \(allout.el)")
;;;_   > allout-version
(defun allout-version (&optional here)
  "Return string describing the loaded allout version."
  (interactive "P")
  (let ((msg (concat "Allout Allout Mode v " allout-version)))
    (if here (insert-string msg))
    (message "%s" msg)
    msg))
;;;_  - Topic header format
;;;_   = allout-regexp
(defvar allout-regexp ""
  "*Regular expression to match the beginning of a heading line.

Any line whose beginning matches this regexp is considered a
heading.  This var is set according to the user configuration vars
by set-allout-regexp.")
(make-variable-buffer-local 'allout-regexp)
;;;_   = allout-bullets-string
(defvar allout-bullets-string ""
  "A string dictating the valid set of allout topic bullets.

This var should *not* be set by the user - it is set by `set-allout-regexp',
and is produced from the elements of `allout-plain-bullets-string'
and `allout-distinctive-bullets-string'.")
(make-variable-buffer-local 'allout-bullets-string)
;;;_   = allout-bullets-string-len
(defvar allout-bullets-string-len 0
  "Length of current buffers' allout-plain-bullets-string.")
(make-variable-buffer-local 'allout-bullets-string-len)
;;;_   = allout-line-boundary-regexp
(defvar allout-line-boundary-regexp ()
  "Allout-regexp with allout-style beginning-of-line anchor.

\(Ie, C-j, *or* C-m, for prefixes of hidden topics).  This is properly
set when allout-regexp is produced by `set-allout-regexp', so
that (match-beginning 2) and (match-end 2) delimit the prefix.")
(make-variable-buffer-local 'allout-line-boundary-regexp)
;;;_   = allout-bob-regexp
(defvar allout-bob-regexp ()
  "Like allout-line-boundary-regexp, for headers at beginning of buffer.
\(match-beginning 2) and (match-end 2) delimit the prefix.")
(make-variable-buffer-local 'allout-bob-regexp)
;;;_   = allout-header-subtraction
(defvar allout-header-subtraction (1- (length allout-header-prefix))
  "Allout-header prefix length to subtract when computing topic depth.")
(make-variable-buffer-local 'allout-header-subtraction)
;;;_   = allout-plain-bullets-string-len
(defvar allout-plain-bullets-string-len (length allout-plain-bullets-string)
  "Length of allout-plain-bullets-string, updated by set-allout-regexp.")
(make-variable-buffer-local 'allout-plain-bullets-string-len)


;;;_   X allout-reset-header-lead (header-lead)
(defun allout-reset-header-lead (header-lead)
  "*Reset the leading string used to identify topic headers."
  (interactive "sNew lead string: ")
  (setq allout-header-prefix header-lead)
  (setq allout-header-subtraction (1- (length allout-header-prefix)))
  (set-allout-regexp))
;;;_   X allout-lead-with-comment-string (header-lead)
(defun allout-lead-with-comment-string (&optional header-lead)
  "*Set the topic-header leading string to specified string.

Useful when for encapsulating allout structure in programming
language comments.  Returns the leading string."

  (interactive "P")
  (if (not (stringp header-lead))
      (setq header-lead (read-string
                         "String prefix for topic headers: ")))
  (setq allout-reindent-bodies nil)
  (allout-reset-header-lead header-lead)
  header-lead)
;;;_   > allout-infer-header-lead ()
(defun allout-infer-header-lead ()
  "Determine appropriate `allout-header-prefix'.

Works according to settings of:

       `comment-start'
       `allout-header-prefix' (default)
       `allout-use-mode-specific-leader'
and    `allout-mode-leaders'.

Apply this via \(re\)activation of `allout-mode', rather than
invoking it directly."
  (let* ((use-leader (and (boundp 'allout-use-mode-specific-leader)
			  (if (or (stringp allout-use-mode-specific-leader)
				  (memq allout-use-mode-specific-leader
					'(allout-mode-leaders
					  comment-start
					  t)))
			      allout-use-mode-specific-leader
			    ;; Oops - garbled value, equate with effect of 't:
			    t)))
	 (leader
	  (cond
	   ((not use-leader) nil)
	   ;; Use the explicitly designated leader:
	   ((stringp use-leader) use-leader)
	   (t (or (and (memq use-leader '(t allout-mode-leaders))
		       ;; Get it from allout mode leaders?
		       (cdr (assq major-mode allout-mode-leaders)))
		  ;; ... didn't get from allout-mode-leaders...
		  (and (memq use-leader '(t comment-start))
		       comment-start
		       ;; Use comment-start, maybe tripled, and with
		       ;; underscore:
		       (concat
			(if (string= " "
				     (substring comment-start
						(1- (length comment-start))))
			    ;; Use comment-start, sans trailing space:
			    (substring comment-start 0 -1)
			  (concat comment-start comment-start comment-start))
			;; ... and append underscore, whichever:
			"_")))))))
    (if (not leader)
	nil
      (if (string= leader allout-header-prefix)
	  nil				; no change, nothing to do.
	(setq allout-header-prefix leader)
	allout-header-prefix))))
;;;_   > allout-infer-body-reindent ()
(defun allout-infer-body-reindent ()
  "Determine proper setting for `allout-reindent-bodies'.

Depends on default setting of `allout-reindent-bodies' \(which see)
and presence of setting for `comment-start', to tell whether the
file is programming code."
  (if (and allout-reindent-bodies
	   comment-start
	   (not (eq 'force allout-reindent-bodies)))
      (setq allout-reindent-bodies nil)))
;;;_   > set-allout-regexp ()
(defun set-allout-regexp ()
  "Generate proper topic-header regexp form for allout functions.

Works with respect to `allout-plain-bullets-string' and
`allout-distinctive-bullets-string'."

  (interactive)
  ;; Derive allout-bullets-string from user configured components:
  (setq allout-bullets-string "")
  (let ((strings (list 'allout-plain-bullets-string
                       'allout-distinctive-bullets-string))
        cur-string
        cur-len
        cur-char
        cur-char-string
        index
        new-string)
    (while strings
      (setq new-string "") (setq index 0)
      (setq cur-len (length (setq cur-string (symbol-value (car strings)))))
      (while (< index cur-len)
        (setq cur-char (aref cur-string index))
        (setq allout-bullets-string
              (concat allout-bullets-string
                      (cond
                                        ; Single dash would denote a
                                        ; sequence, repeated denotes
                                        ; a dash:
                       ((eq cur-char ?-) "--")
                                        ; literal close-square-bracket
                                        ; doesn't work right in the
                                        ; expr, exclude it:
                       ((eq cur-char ?\]) "")
                       (t (regexp-quote  (char-to-string cur-char))))))
        (setq index (1+ index)))
      (setq strings (cdr strings)))
    )
  ;; Derive next for repeated use in allout-pending-bullet:
  (setq allout-plain-bullets-string-len (length allout-plain-bullets-string))
  (setq allout-header-subtraction (1- (length allout-header-prefix)))
  ;; Produce the new allout-regexp:
  (setq allout-regexp (concat "\\(\\"
                               allout-header-prefix
                               "[ \t]*["
                               allout-bullets-string
                               "]\\)\\|\\"
                               allout-primary-bullet
                               "+\\|\^l"))
  (setq allout-line-boundary-regexp
        (concat "\\([\n\r]\\)\\(" allout-regexp "\\)"))
  (setq allout-bob-regexp
        (concat "\\(\\`\\)\\(" allout-regexp "\\)"))
  )
;;;_  - Key bindings
;;;_   = allout-mode-map
(defvar allout-mode-map nil "Keybindings for (allout) allout minor mode.")
;;;_   > produce-allout-mode-map (keymap-alist &optional base-map)
(defun produce-allout-mode-map (keymap-list &optional base-map)
  "Produce keymap for use as allout-mode-map, from keymap-list.

Built on top of optional BASE-MAP, or empty sparse map if none specified.
See doc string for allout-keybindings-list for format of binding list."
  (let ((map (or base-map (make-sparse-keymap))))
    (mapcar (lambda (cell)
	      (apply 'define-key map (if (null (cdr (cdr cell)))
					 (cons (concat allout-command-prefix
						       (car cell))
					       (cdr cell))
				       (list (car cell) (car (cdr cell))))))
	    keymap-list)
    map))
;;;_   = allout-prior-bindings - being deprecated.
(defvar allout-prior-bindings nil
  "Variable for use in V18, with allout-added-bindings, for
resurrecting, on mode deactivation, bindings that existed before
activation.  Being deprecated.")
;;;_   = allout-added-bindings - being deprecated
(defvar allout-added-bindings nil
  "Variable for use in V18, with allout-prior-bindings, for
resurrecting, on mode deactivation, bindings that existed before
activation.  Being deprecated.")
;;;_  - Mode-Specific Variable Maintenance Utilities
;;;_   = allout-mode-prior-settings
(defvar allout-mode-prior-settings nil
  "Internal allout mode use; settings to be resumed on mode deactivation.")
(make-variable-buffer-local 'allout-mode-prior-settings)
;;;_   > allout-resumptions (name &optional value)
(defun allout-resumptions (name &optional value)

  "Registers or resumes settings over allout-mode activation/deactivation.

First arg is NAME of variable affected.  Optional second arg is list
containing allout-mode-specific VALUE to be imposed on named
variable, and to be registered.  (It's a list so you can specify
registrations of null values.)  If no value is specified, the
registered value is returned (encapsulated in the list, so the caller
can distinguish nil vs no value), and the registration is popped
from the list."

  (let ((on-list (assq name allout-mode-prior-settings))
        prior-capsule                   ; By `capsule' i mean a list
                                        ; containing a value, so we can
                                        ; distinguish nil from no value.
        )

    (if value

        ;; Registering:
        (progn
          (if on-list
              nil 	; Already preserved prior value - don't mess with it.
            ;; Register the old value, or nil if previously unbound:
            (setq allout-mode-prior-settings
                  (cons (list name
                              (if (boundp name) (list (symbol-value name))))
                        allout-mode-prior-settings)))
                                        ; And impose the new value, locally:
	  (progn (make-local-variable name)
		 (set name (car value))))

      ;; Relinquishing:
      (if (not on-list)

          ;; Oops, not registered - leave it be:
          nil

        ;; Some registration:
                                        ; reestablish it:
        (setq prior-capsule (car (cdr on-list)))
        (if prior-capsule
            (set name (car prior-capsule)) ; Some prior value - reestablish it.
          (makunbound name))		; Previously unbound - demolish var.
                                        ; Remove registration:
        (let (rebuild)
          (while allout-mode-prior-settings
            (if (not (eq (car allout-mode-prior-settings)
                         on-list))
                (setq rebuild
                      (cons (car allout-mode-prior-settings)
                            rebuild)))
            (setq allout-mode-prior-settings
                  (cdr allout-mode-prior-settings)))
          (setq allout-mode-prior-settings rebuild)))))
  )
;;;_  - Mode-specific incidentals
;;;_   = allout-during-write-cue nil
(defvar allout-during-write-cue nil
  "Used to inhibit allout change-protection during file write.

See also `allout-post-command-business', `allout-write-file-hook',
`allout-before-change-protect', and `allout-post-command-business'
functions.")
;;;_   = allout-override-protect nil
(defvar allout-override-protect nil
  "Used in allout-mode for regulate of concealed-text protection mechanism.

Allout allout mode regulates alteration of concealed text to protect
against inadvertent, unnoticed changes.  This is for use by specific,
native allout functions to temporarily override that protection.
It's automatically reset to nil after every buffer modification.")
(make-variable-buffer-local 'allout-override-protect)
;;;_   > allout-unprotected (expr)
(defmacro allout-unprotected (expr)
  "Evaluate EXPRESSION with `allout-override-protect' let-bound to t."
  (` (let ((allout-override-protect t))
       (, expr))))
;;;_   = allout-undo-aggregation
(defvar allout-undo-aggregation 30
  "Amount of successive self-insert actions to bunch together per undo.

This is purely a kludge variable, regulating the compensation for a bug in
the way that before-change-function and undo interact.")
(make-variable-buffer-local 'allout-undo-aggregation)
;;;_   = file-var-bug hack
(defvar allout-v18/9-file-var-hack nil
  "Horrible hack used to prevent invalid multiple triggering of allout
mode from prop-line file-var activation.  Used by allout-mode function
to track repeats.")
;;;_   > allout-write-file-hook ()
(defun allout-write-file-hook ()
  "In allout mode, run as a local-write-file-hooks activity.

Currently just sets `allout-during-write-cue', so allout-change-protection
knows to keep inactive during file write."
  (setq allout-during-write-cue t)
  nil)

;;;_ #2 Mode activation
;;;_  = allout-mode
(defvar allout-mode () "Allout allout mode minor-mode flag.")
(make-variable-buffer-local 'allout-mode)
;;;_  > allout-mode-p ()
(defmacro allout-mode-p ()
  "Return t if allout-mode is active in current buffer."
  'allout-mode)
;;;_  = allout-explicitly-deactivated
(defvar allout-explicitly-deactivated nil
  "Allout-mode was last deliberately deactivated.
So allout-post-command-business should not reactivate it...")
(make-variable-buffer-local 'allout-explicitly-deactivated)
;;;_  > allout-init (&optional mode)
(defun allout-init (&optional mode)
  "Prime allout-mode to enable/disable auto-activation, wrt `allout-layout'.

MODE is one of the following symbols:

 - nil \(or no argument) deactivate auto-activation/layout;
 - `activate', enable auto-activation only;
 - `ask', enable auto-activation, and enable auto-layout but with
   confirmation for layout operation solicited from user each time;
 - `report', just report and return the current auto-activation state;
 - anything else \(eg, t) for auto-activation and auto-layout, without
   any confirmation check.

Use this function to setup your emacs session for automatic activation
of allout allout mode, contingent to the buffer-specific setting of
the `allout-layout' variable.  (See `allout-layout' and
`allout-expose-topic' docstrings for more details on auto layout).

`allout-init' works by setting up (or removing) the allout-mode
find-file-hook, and giving `allout-auto-activation' a suitable
setting.

To prime your emacs session for full auto-allout operation, include
the following two lines in your emacs init file:

\(require 'allout)
\(allout-init t)"

  (interactive)
  (if (interactive-p)
      (progn
	(setq mode
	      (completing-read
	       (concat "Select allout auto setup mode "
		       "(empty for report, ? for options) ")
	       '(("nil")("full")("activate")("deactivate")
		 ("ask") ("report") (""))
	       nil
	       t))
	(if (string= mode "")
	    (setq mode 'report)
	  (setq mode (intern-soft mode)))))
  (let
      ;; convenience aliases, for consistent ref to respective vars:
      ((hook 'allout-find-file-hook)
       (curr-mode 'allout-auto-activation))

    (cond ((not mode)
	   (setq find-file-hooks (delq hook find-file-hooks))
	   (if (interactive-p)
	       (message "Allout allout mode auto-activation inhibited.")))
	  ((eq mode 'report)
	   (if (not (memq hook find-file-hooks))
	       (allout-init nil)
	     ;; Just punt and use the reports from each of the modes:
	     (allout-init (symbol-value curr-mode))))
	  (t (add-hook 'find-file-hooks hook)
	     (set curr-mode		; `set', not `setq'!
		  (cond ((eq mode 'activate)
			 (message
			  "Allout mode auto-activation enabled.")
			 'activate)
			((eq mode 'report)
			 ;; Return the current mode setting:
			 (allout-init mode))
			((eq mode 'ask)
			 (message
			  (concat "Allout mode auto-activation and "
				  "-layout \(upon confirmation) enabled."))
			 'ask)
			((message
			  "Allout mode auto-activation and -layout enabled.")
			 'full)))))))

;;;_  > allout-mode (&optional toggle)
;;;_   : Defun:
(defun allout-mode (&optional toggle)
;;;_    . Doc string:
  "Toggle minor mode for controlling exposure and editing of text outlines.

Optional arg forces mode reactivation iff arg is positive num or symbol.

Allout allout mode provides extensive allout formatting and
manipulation capabilities.  It is specifically aimed at supporting
allout structuring and manipulation of syntax-sensitive text, eg
programming languages.  \(For an example, see the allout code itself,
which is organized in allout structure.\)

It also includes such things as topic-oriented repositioning, cut, and
paste; integral allout exposure-layout; incremental search with
dynamic exposure/concealment of concealed text; automatic topic-number
maintenance; and many other features.

See the docstring of the variable `allout-init' for instructions on
priming your emacs session for automatic activation of allout-mode,
according to file-var settings of the `allout-layout' variable.

Below is a description of the bindings, and then explanation of
special allout-mode features and terminology.

The bindings themselves are established according to the values of
variables `allout-keybindings-list' and `allout-command-prefix',
each time the mode is invoked.  Prior bindings are resurrected when
the mode is revoked.

	Navigation:				   Exposure Control:
	----------                                 ----------------
C-c C-n allout-next-visible-heading     | C-c C-h allout-hide-current-subtree
C-c C-p allout-previous-visible-heading | C-c C-i allout-show-children
C-c C-u allout-up-current-level         | C-c C-s allout-show-current-subtree
C-c C-f allout-forward-current-level    | C-c C-o allout-show-current-entry
C-c C-b allout-backward-current-level   | ^U C-c C-s allout-show-all
C-c C-e allout-end-of-current-entry     |	   allout-hide-current-leaves
C-c C-a allout-beginning-of-current-entry, alternately, goes to hot-spot

	Topic Header Production:
	-----------------------
C-c<SP>	allout-open-sibtopic	Create a new sibling after current topic.
C-c .	allout-open-subtopic	... an offspring of current topic.
C-c ,	allout-open-supertopic	... a sibling of the current topic's parent.

	Topic Level and Prefix Adjustment:
	---------------------------------
C-c >	allout-shift-in	Shift current topic and all offspring deeper.
C-c <	allout-shift-out	... less deep.
C-c<CR>	allout-rebullet-topic	Reconcile bullets of topic and its offspring
				- distinctive bullets are not changed, others
				  alternated according to nesting depth.
C-c *	allout-rebullet-current-heading Prompt for alternate bullet for
					 current topic.
C-c #	allout-number-siblings	Number bullets of topic and siblings - the
				offspring are not affected.  With repeat
				count, revoke numbering.

	Topic-oriented Killing and Yanking:
	----------------------------------
C-c C-k	allout-kill-topic	Kill current topic, including offspring.
C-k	allout-kill-line	Like kill-line, but reconciles numbering, etc.
C-y	allout-yank		Yank, adjusting depth of yanked topic to
				depth of heading if yanking into bare topic
				heading (ie, prefix sans text).
M-y	allout-yank-pop	Is to allout-yank as yank-pop is to yank

	Misc commands:
	-------------
C-c @   allout-resolve-xref    pop-to-buffer named by xref (cf
				allout-file-xref-bullet)
C-c c	allout-copy-exposed	Copy current topic allout sans concealed
				text, to buffer with name derived from
				current buffer - \"XXX exposed\"
M-x outlineify-sticky		Activate allout mode for current buffer,
				and establish a default file-var setting
				for `allout-layout'.
ESC ESC (allout-init t)	Setup emacs session for allout mode
				auto-activation.

		 HOT-SPOT Operation

Hot-spot operation provides a means for easy, single-keystroke allout
navigation and exposure control.

\\<allout-mode-map>
When the text cursor is positioned directly on the bullet character of
a topic, regular characters (a to z) invoke the commands of the
corresponding allout-mode keymap control chars.  For example, \"f\"
would invoke the command typically bound to \"C-c C-f\"
\(\\[allout-forward-current-level] `allout-forward-current-level').

Thus, by positioning the cursor on a topic bullet, you can execute
the allout navigation and manipulation commands with a single
keystroke.  Non-literal chars never get this special translation, so
you can use them to get away from the hot-spot, and back to normal
operation.

Note that the command `allout-beginning-of-current-entry' \(\\[allout-beginning-of-current-entry]\)
will move to the hot-spot when the cursor is already located at the
beginning of the current entry, so you can simply hit \\[allout-beginning-of-current-entry]
twice in a row to get to the hot-spot.

			    Terminology

Topic hierarchy constituents - TOPICS and SUBTOPICS:

TOPIC:	A basic, coherent component of an emacs allout.  It can
	contain other topics, and it can be subsumed by other topics,
CURRENT topic:
	The visible topic most immediately containing the cursor.
DEPTH:	The degree of nesting of a topic; it increases with
	containment.  Also called the:
LEVEL:	The same as DEPTH.

ANCESTORS:
	The topics that contain a topic.
PARENT:	A topic's immediate ancestor.  It has a depth one less than
	the topic.
OFFSPRING:
	The topics contained by a topic;
SUBTOPIC:
	An immediate offspring of a topic;
CHILDREN:
	The immediate offspring of a topic.
SIBLINGS:
	Topics having the same parent and depth.

Topic text constituents:

HEADER:	The first line of a topic, include the topic PREFIX and header
	text.
PREFIX: The leading text of a topic which which distinguishes it from
	normal text.  It has a strict form, which consists of a
	prefix-lead string, padding, and a bullet.  The bullet may be
	followed by a number, indicating the ordinal number of the
	topic among its siblings, a space, and then the header text.

	The relative length of the PREFIX determines the nesting depth
	of the topic.
PREFIX-LEAD:
	The string at the beginning of a topic prefix, normally a `.'.
	It can be customized by changing the setting of
	`allout-header-prefix' and then reinitializing allout-mode.

	By setting the prefix-lead to the comment-string of a
	programming language, you can embed allout-structuring in
	program code without interfering with the language processing
	of that code.  See `allout-use-mode-specific-leader'
	docstring for more detail.
PREFIX-PADDING:
	Spaces or asterisks which separate the prefix-lead and the
	bullet, according to the depth of the topic.
BULLET: A character at the end of the topic prefix, it must be one of
	the characters listed on `allout-plain-bullets-string' or
        `allout-distinctive-bullets-string'.  (See the documentation
        for these variables for more details.)  The default choice of
	bullet when generating varies in a cycle with the depth of the
	topic.
ENTRY:	The text contained in a topic before any offspring.
BODY:	Same as ENTRY.


EXPOSURE:
 	The state of a topic which determines the on-screen visibility
	of its offspring and contained text.
CONCEALED:
	Topics and entry text whose display is inhibited.  Contiguous
	units of concealed text is represented by `...' ellipses.
	(Ref the `selective-display' var.)

	Concealed topics are effectively collapsed within an ancestor.
CLOSED:	A topic whose immediate offspring and body-text is concealed.
OPEN:	A topic that is not closed, though its offspring or body may be."
;;;_    . Code
  (interactive "P")

  (let* ((active (and (not (equal major-mode 'allout))
		     (allout-mode-p)))
				       ; Massage universal-arg `toggle' val:
	 (toggle (and toggle
		     (or (and (listp toggle)(car toggle))
			 toggle)))
				       ; Activation specifically demanded?
	 (explicit-activation (or
			      ;;
			      (and toggle
				   (or (symbolp toggle)
				       (and (natnump toggle)
					    (not (zerop toggle)))))))
	 ;; allout-mode already called once during this complex command?
	 (same-complex-command (eq allout-v18/9-file-var-hack
				  (car command-history)))
	 do-layout
	 )

				       ; See comments below re v19.18,.19 bug.
    (setq allout-v18/9-file-var-hack (car command-history))

    (cond

     ;; Provision for v19.18, 19.19 bug -
     ;; Emacs v 19.18, 19.19 file-var code invokes prop-line-designated
     ;; modes twice when file is visited.  We have to avoid toggling mode
     ;; off on second invocation, so we detect it as best we can, and
     ;; skip everything.
     ((and same-complex-command		; Still in same complex command
				       ; as last time allout-mode invoked.
	  active			; Already activated.
	  (not explicit-activation)	; Prop-line file-vars don't have args.
	  (string-match "^19.1[89]"	; Bug only known to be in v19.18 and
			emacs-version)); 19.19.
      t)

     ;; Deactivation:
     ((and (not explicit-activation)
	  (or active toggle))
				       ; Activation not explicitly
				       ; requested, and either in
				       ; active state or *de*activation
				       ; specifically requested:
      (setq allout-explicitly-deactivated t)
      (if (string-match "^18\." emacs-version)
				       ; Revoke those keys that remain
				       ; as we set them:
	  (let ((curr-loc (current-local-map)))
	   (mapcar '(lambda (cell)
		      (if (eq (lookup-key curr-loc (car cell))
			      (car (cdr cell)))
			  (define-key curr-loc (car cell)
			    (assq (car cell) allout-prior-bindings))))
		   allout-added-bindings)
	   (allout-resumptions 'allout-added-bindings)
	   (allout-resumptions 'allout-prior-bindings)))

      (if allout-old-style-prefixes
	  (progn
	   (allout-resumptions 'allout-primary-bullet)
	   (allout-resumptions 'allout-old-style-prefixes)))
      (allout-resumptions 'selective-display)
      (if (and (boundp 'before-change-function) before-change-function)
	  (allout-resumptions 'before-change-function))
      (setq pre-command-hook (delq 'allout-pre-command-business
				  pre-command-hook))
      (setq local-write-file-hooks
	   (delq 'allout-write-file-hook
		 local-write-file-hooks))
      (allout-resumptions 'paragraph-start)
      (allout-resumptions 'paragraph-separate)
      (allout-resumptions (if (string-match "^18" emacs-version)
			      'auto-fill-hook
			    'auto-fill-function))
      (allout-resumptions 'allout-former-auto-filler)
      (setq allout-mode nil))

     ;; Activation:
     ((not active)
      (setq allout-explicitly-deactivated nil)
      (if allout-old-style-prefixes
	  (progn			; Inhibit all the fancy formatting:
	   (allout-resumptions 'allout-primary-bullet '("*"))
	   (allout-resumptions 'allout-old-style-prefixes '(()))))

      (allout-infer-header-lead)
      (allout-infer-body-reindent)

      (set-allout-regexp)

				       ; Produce map from current version
				       ; of allout-keybindings-list:
      (if (boundp 'minor-mode-map-alist)

	  (progn			; V19, and maybe lucid and
				       ; epoch, minor-mode key bindings:
	   (setq allout-mode-map
		 (produce-allout-mode-map allout-keybindings-list))
	   (fset 'allout-mode-map allout-mode-map)
				       ; Include on minor-mode-map-alist,
				       ; if not already there:
	   (if (not (member '(allout-mode . allout-mode-map)
			    minor-mode-map-alist))
	       (setq minor-mode-map-alist
		     (cons '(allout-mode . allout-mode-map)
			   minor-mode-map-alist))))

				       ; V18 minor-mode key bindings:
				       ; Stash record of added bindings
				       ; for later revocation:
	(allout-resumptions 'allout-added-bindings
			    (list allout-keybindings-list))
	(allout-resumptions 'allout-prior-bindings
			    (list (current-local-map)))
				       ; and add them:
	(use-local-map (produce-allout-mode-map allout-keybindings-list
						(current-local-map)))
	)

				       ; selective-display is the
				       ; emacs conditional exposure
				       ; mechanism:
      (allout-resumptions 'selective-display '(t))
      (if allout-inhibit-protection
	  t
	(allout-resumptions 'before-change-function
			    '(allout-before-change-protect)))
				       ; Temporarily set by any allout
				       ; functions that can be trusted to
				       ; deal properly with concealed text.
      (add-hook 'local-write-file-hooks 'allout-write-file-hook)
				       ; Custom auto-fill func, to support
				       ; respect for topic headline,
				       ; hanging-indents, etc:
      (let* ((fill-func-var (if (string-match "^18" emacs-version)
			       'auto-fill-hook
			     'auto-fill-function))
	    (fill-func (symbol-value fill-func-var)))
	;; Register prevailing fill func for use by allout-auto-fill:
	(allout-resumptions 'allout-former-auto-filler (list fill-func))
	;; Register allout-auto-fill to be used if filling is active:
	(allout-resumptions fill-func-var '(allout-auto-fill)))
      ;; Paragraphs are broken by topic headlines.
      (make-local-variable 'paragraph-start)
      (allout-resumptions 'paragraph-start
			  (list (concat paragraph-start "\\|\\("
					allout-regexp "\\)")))
      (make-local-variable 'paragraph-separate)
      (allout-resumptions 'paragraph-separate
			  (list (concat paragraph-separate "\\|\\("
					allout-regexp "\\)")))

      (or (assq 'allout-mode minor-mode-alist)
	  (setq minor-mode-alist
	       (cons '(allout-mode " Outl") minor-mode-alist)))

      (if allout-layout
	  (setq do-layout t))

      (if allout-enwrap-isearch-mode
	  (allout-enwrap-isearch))

      (run-hooks 'allout-mode-hook)
      (setq allout-mode t))

     ;; Reactivation:
     ((setq do-layout t)
      (allout-infer-body-reindent))
     )					; cond

    (if (and do-layout
	     allout-auto-activation
	     (listp allout-layout)
	     (and (not (eq allout-auto-activation 'activate))
		  (if (eq allout-auto-activation 'ask)
		      (if (y-or-n-p (format "Expose %s with layout '%s'? "
					    (buffer-name)
					    allout-layout))
			  t
			(message "Skipped %s layout." (buffer-name))
			nil)
		    t)))
	(save-excursion
	  (message "Adjusting '%s' exposure..." (buffer-name))
	  (goto-char 0)
	  (allout-this-or-next-heading)
	  (condition-case err
	      (progn
		(apply 'allout-expose-topic (list allout-layout))
		(message "Adjusting '%s' exposure... done." (buffer-name)))
	    ;; Problem applying exposure - notify user, but don't
	    ;; interrupt, eg, file visit:
	    (error (message "%s" (car (cdr err)))
		   (sit-for 1)))))
    allout-mode
    )					; let*
  )  					; defun

;;;_ #3 Internal Position State-Tracking - "allout-recent-*" funcs
;;; All the basic allout functions that directly do string matches to
;;; evaluate heading prefix location set the variables
;;; `allout-recent-prefix-beginning'  and `allout-recent-prefix-end'
;;; when successful.  Functions starting with `allout-recent-' all
;;; use this state, providing the means to avoid redundant searches
;;; for just-established data.  This optimization can provide
;;; significant speed improvement, but it must be employed carefully.
;;;_  = allout-recent-prefix-beginning
(defvar allout-recent-prefix-beginning 0
  "Buffer point of the start of the last topic prefix encountered.")
(make-variable-buffer-local 'allout-recent-prefix-beginning)
;;;_  = allout-recent-prefix-end
(defvar allout-recent-prefix-end 0
  "Buffer point of the end of the last topic prefix encountered.")
(make-variable-buffer-local 'allout-recent-prefix-end)
;;;_  = allout-recent-end-of-subtree
(defvar allout-recent-end-of-subtree 0
  "Buffer point last returned by allout-end-of-current-subtree.")
(make-variable-buffer-local 'allout-recent-end-of-subtree)
;;;_  > allout-prefix-data (beg end)
(defmacro allout-prefix-data (beg end)
  "Register allout-prefix state data - BEGINNING and END of prefix.

For reference by `allout-recent' funcs.  Returns BEGINNING."
  (` (setq allout-recent-prefix-end (, end)
	   allout-recent-prefix-beginning (, beg))))
;;;_  > allout-recent-depth ()
(defmacro allout-recent-depth ()
  "Return depth of last heading encountered by an allout maneuvering function.

All allout functions which directly do string matches to assess
headings set the variables allout-recent-prefix-beginning and
allout-recent-prefix-end if successful.  This function uses those settings
to return the current depth."

  '(max 1 (- allout-recent-prefix-end
	     allout-recent-prefix-beginning
	     allout-header-subtraction)))
;;;_  > allout-recent-prefix ()
(defmacro allout-recent-prefix ()
  "Like allout-recent-depth, but returns text of last encountered prefix.

All allout functions which directly do string matches to assess
headings set the variables allout-recent-prefix-beginning and
allout-recent-prefix-end if successful.  This function uses those settings
to return the current depth."
  '(buffer-substring allout-recent-prefix-beginning
		     allout-recent-prefix-end))
;;;_  > allout-recent-bullet ()
(defmacro allout-recent-bullet ()
  "Like allout-recent-prefix, but returns bullet of last encountered prefix.

All allout functions which directly do string matches to assess
headings set the variables allout-recent-prefix-beginning and
allout-recent-prefix-end if successful.  This function uses those settings
to return the current depth of the most recently matched topic."
  '(buffer-substring (1- allout-recent-prefix-end)
		     allout-recent-prefix-end))

;;;_ #4 Navigation

;;;_  - Position Assessment
;;;_   : Location Predicates
;;;_    > allout-on-current-heading-p ()
(defun allout-on-current-heading-p ()
  "Return non-nil if point is on current visible topics' header line.

Actually, returns prefix beginning point."
  (save-excursion
    (beginning-of-line)
    (and (looking-at allout-regexp)
	 (allout-prefix-data (match-beginning 0) (match-end 0)))))
;;;_    > allout-e-o-prefix-p ()
(defun allout-e-o-prefix-p ()
  "True if point is located where current topic prefix ends, heading begins."
  (and (save-excursion (beginning-of-line)
		       (looking-at allout-regexp))
       (= (point)(save-excursion (allout-end-of-prefix)(point)))))
;;;_    > allout-hidden-p ()
(defmacro allout-hidden-p ()
  "True if point is in hidden text."
  '(save-excursion
     (and (re-search-backward "[\n\r]" () t)
	  (= ?\r (following-char)))))
;;;_    > allout-visible-p ()
(defmacro allout-visible-p ()
  "True if point is not in hidden text."
  (interactive)
  '(not (allout-hidden-p)))
;;;_   : Location attributes
;;;_    > allout-depth ()
(defmacro allout-depth ()
  "Like allout-current-depth, but respects hidden as well as visible topics."
  '(save-excursion
     (if (allout-goto-prefix)
	 (allout-recent-depth)
       (progn
	 ;; Oops, no prefix, zero prefix data:
	 (allout-prefix-data (point)(point))
	 ;; ... and return 0:
	 0))))
;;;_    > allout-current-depth ()
(defmacro allout-current-depth ()
  "Return nesting depth of visible topic most immediately containing point."
  '(save-excursion
     (if (allout-back-to-current-heading)
	 (max 1
	      (- allout-recent-prefix-end
		 allout-recent-prefix-beginning
		 allout-header-subtraction))
       0)))
;;;_    > allout-get-current-prefix ()
(defun allout-get-current-prefix ()
  "Topic prefix of the current topic."
  (save-excursion
    (if (allout-goto-prefix)
	(allout-recent-prefix))))
;;;_    > allout-get-bullet ()
(defun allout-get-bullet ()
  "Return bullet of containing topic (visible or not)."
  (save-excursion
    (and (allout-goto-prefix)
	 (allout-recent-bullet))))
;;;_    > allout-current-bullet ()
(defun allout-current-bullet ()
  "Return bullet of current (visible) topic heading, or none if none found."
  (condition-case err
      (save-excursion
	(allout-back-to-current-heading)
	(buffer-substring (- allout-recent-prefix-end 1)
			  allout-recent-prefix-end))
    ;; Quick and dirty provision, ostensibly for missing bullet:
    (args-out-of-range nil))
  )
;;;_    > allout-get-prefix-bullet (prefix)
(defun allout-get-prefix-bullet (prefix)
  "Return the bullet of the header prefix string PREFIX."
  ;; Doesn't make sense if we're old-style prefixes, but this just
  ;; oughtn't be called then, so forget about it...
  (if (string-match allout-regexp prefix)
      (substring prefix (1- (match-end 0)) (match-end 0))))

;;;_  - Navigation macros
;;;_   > allout-next-heading ()
(defmacro allout-next-heading ()
  "Move to the heading for the topic \(possibly invisible) before this one.

Returns the location of the heading, or nil if none found."

  '(if (and (bobp) (not (eobp)))
       (forward-char 1))

  '(if (re-search-forward allout-line-boundary-regexp nil 0)
       (progn				; Got valid location state - set vars:
	 (allout-prefix-data
	  (goto-char (or (match-beginning 2)
			 allout-recent-prefix-beginning))
	  (or (match-end 2) allout-recent-prefix-end)))))
;;;_   : allout-this-or-next-heading
(defun allout-this-or-next-heading ()
  "Position cursor on current or next heading."
  ;; A throwaway non-macro that is defined after allout-next-heading
  ;; and usable by allout-mode.
  (if (not (allout-goto-prefix)) (allout-next-heading)))
;;;_   > allout-previous-heading ()
(defmacro allout-previous-heading ()
  "Move to the prior \(possibly invisible) heading line.

Return the location of the beginning of the heading, or nil if not found."

  '(if (bobp)
       nil
     (allout-goto-prefix)
     (if
	 ;; searches are unbounded and return nil if failed:
	 (or (re-search-backward allout-line-boundary-regexp nil 0)
	     (looking-at allout-bob-regexp))
	 (progn				; Got valid location state - set vars:
	   (allout-prefix-data
	    (goto-char (or (match-beginning 2)
			   allout-recent-prefix-beginning))
	    (or (match-end 2) allout-recent-prefix-end))))))

;;;_  - Subtree Charting
;;;_   " These routines either produce or assess charts, which are
;;; nested lists of the locations of topics within a subtree.
;;;
;;; Use of charts enables efficient navigation of subtrees, by
;;; requiring only a single regexp-search based traversal, to scope
;;; out the subtopic locations.  The chart then serves as the basis
;;; for whatever assessment or adjustment of the subtree that is
;;; required, without requiring redundant topic-traversal procedures.

;;;_   > allout-chart-subtree (&optional levels orig-depth prev-depth)
(defun allout-chart-subtree (&optional levels orig-depth prev-depth)
  "Produce a location \"chart\" of subtopics of the containing topic.

Optional argument LEVELS specifies the depth \(relative to start
depth\) for the chart.  Subsequent optional args are not for public
use.

Charts are used to capture allout structure, so that allout-altering
routines need assess the structure only once, and then use the chart
for their elaborate manipulations.

Topics are entered in the chart so the last one is at the car.
The entry for each topic consists of an integer indicating the point
at the beginning of the topic.  Charts for offspring consists of a
list containing, recursively, the charts for the respective subtopics.
The chart for a topics' offspring precedes the entry for the topic
itself.

The other function parameters are for internal recursion, and should
not be specified by external callers.  ORIG-DEPTH is depth of topic at
starting point, and PREV-DEPTH is depth of prior topic."

  (let ((original (not orig-depth))	; `orig-depth' set only in recursion.
	chart curr-depth)

    (if original			; Just starting?
					; Register initial settings and
					; position to first offspring:
	(progn (setq orig-depth (allout-depth))
	       (or prev-depth (setq prev-depth (1+ orig-depth)))
	       (allout-next-heading)))

    ;; Loop over the current levels' siblings.  Besides being more
    ;; efficient than tail-recursing over a level, it avoids exceeding
    ;; the typically quite constrained emacs max-lisp-eval-depth.
    ;; Probably would speed things up to implement loop-based stack
    ;; operation rather than recursing for lower levels.  Bah.
    (while (and (not (eobp))
					; Still within original topic?
		(< orig-depth (setq curr-depth (allout-recent-depth)))
		(cond ((= prev-depth curr-depth)
		       ;; Register this one and move on:
		       (setq chart (cons (point) chart))
		       (if (and levels (<= levels 1))
			   ;; At depth limit - skip sublevels:
			   (or (allout-next-sibling curr-depth)
			       ;; or no more siblings - proceed to
			       ;; next heading at lesser depth:
			       (while (and (<= curr-depth
					       (allout-recent-depth))
					   (allout-next-heading))))
			 (allout-next-heading)))

		      ((and (< prev-depth curr-depth)
			    (or (not levels)
				(> levels 0)))
		       ;; Recurse on deeper level of curr topic:
		       (setq chart
			     (cons (allout-chart-subtree (and levels
							       (1- levels))
							  orig-depth
							  curr-depth)
				   chart))
		       ;; ... then continue with this one.
		       )

		      ;; ... else nil if we've ascended back to prev-depth.

		      )))

    (if original			; We're at the last sibling on
					; the original level.  Position
					; to the end of it:
	(progn (and (not (eobp)) (forward-char -1))
	       (and (memq (preceding-char) '(?\n ?\^M))
		    (memq (aref (buffer-substring (max 1 (- (point) 3))
						  (point))
				1)
			  '(?\n ?\^M))
		    (forward-char -1))
	       (setq allout-recent-end-of-subtree (point))))

    chart				; (nreverse chart) not necessary,
					; and maybe not preferable.
    ))
;;;_   > allout-chart-siblings (&optional start end)
(defun allout-chart-siblings (&optional start end)
  "Produce a list of locations of this and succeeding sibling topics.
Effectively a top-level chart of siblings.  See `allout-chart-subtree'
for an explanation of charts."
  (save-excursion
    (if (allout-goto-prefix)
	(let ((chart (list (point))))
	  (while (allout-next-sibling)
	    (setq chart (cons (point) chart)))
	  (if chart (setq chart (nreverse chart)))))))
;;;_   > allout-chart-to-reveal (chart depth)
(defun allout-chart-to-reveal (chart depth)

  "Return a flat list of hidden points in subtree CHART, up to DEPTH.

Note that point can be left at any of the points on chart, or at the
start point."

  (let (result here)
    (while (and (or (eq depth t) (> depth 0))
		chart)
      (setq here (car chart))
      (if (listp here)
	  (let ((further (allout-chart-to-reveal here (or (eq depth t)
							   (1- depth)))))
	    ;; We're on the start of a subtree - recurse with it, if there's
	    ;; more depth to go:
	    (if further (setq result (append further result)))
	    (setq chart (cdr chart)))
	(goto-char here)
	(if (= (preceding-char) ?\r)
	    (setq result (cons here result)))
	(setq chart (cdr chart))))
    result))
;;;_   X allout-chart-spec (chart spec &optional exposing)
(defun allout-chart-spec (chart spec &optional exposing)
  "Not yet \(if ever\) implemented.

Produce exposure directives given topic/subtree CHART and an exposure SPEC.

Exposure spec indicates the locations to be exposed and the prescribed
exposure status.  Optional arg EXPOSING is an integer, with 0
indicating pending concealment, anything higher indicating depth to
which subtopic headers should be exposed, and negative numbers
indicating (negative of) the depth to which subtopic headers and
bodies should be exposed.

The produced list can have two types of entries.  Bare numbers
indicate points in the buffer where topic headers that should be
exposed reside.

 - bare negative numbers indicates that the topic starting at the
   point which is the negative of the number should be opened,
   including their entries.
 - bare positive values indicate that this topic header should be
   opened.
 - Lists signify the beginning and end points of regions that should
   be flagged, and the flag to employ.  (For concealment: `\(\?r\)', and
   exposure:"
  (while spec
    (cond ((listp spec)
	   )
	  )
    (setq spec (cdr spec)))
  )

;;;_  - Within Topic
;;;_   > allout-goto-prefix ()
(defun allout-goto-prefix ()
  "Put point at beginning of allout prefix for immediately containing topic.

Goes to first subsequent topic if none immediately containing.

Not sensitive to topic visibility.

Returns a the point at the beginning of the prefix, or nil if none."

  (let (done)
    (while (and (not done)
		(re-search-backward "[\n\r]" nil 1))
      (forward-char 1)
      (if (looking-at allout-regexp)
	  (setq done (allout-prefix-data (match-beginning 0)
					  (match-end 0)))
	(forward-char -1)))
    (if (bobp)
	(cond ((looking-at allout-regexp)
	       (allout-prefix-data (match-beginning 0)(match-end 0)))
	      ((allout-next-heading)
	       (allout-prefix-data (match-beginning 0)(match-end 0)))
	      (done))
      done)))
;;;_   > allout-end-of-prefix ()
(defun allout-end-of-prefix (&optional ignore-decorations)
  "Position cursor at beginning of header text.

If optional IGNORE-DECORATIONS is non-nil, put just after bullet,
otherwise skip white space between bullet and ensuing text."

  (if (not (allout-goto-prefix))
      nil
    (let ((match-data (match-data)))
      (goto-char (match-end 0))
      (if ignore-decorations
	  t
	(while (looking-at "[0-9]") (forward-char 1))
	(if (and (not (eolp)) (looking-at "\\s-")) (forward-char 1)))
      (set-match-data match-data))
    ;; Reestablish where we are:
    (allout-current-depth)))
;;;_   > allout-current-bullet-pos ()
(defun allout-current-bullet-pos ()
  "Return position of current \(visible) topic's bullet."

 (if (not (allout-current-depth))
      nil
   (1- (match-end 0))))
;;;_   > allout-back-to-current-heading ()
(defun allout-back-to-current-heading ()
  "Move to heading line of current topic, or beginning if already on the line."

  (beginning-of-line)
  (prog1 (or (allout-on-current-heading-p)
             (and (re-search-backward (concat "^\\(" allout-regexp "\\)")
                                      nil
                                      'move)
                  (allout-prefix-data (match-beginning 1)(match-end 1))))
    (if (interactive-p) (allout-end-of-prefix))))
;;;_   > allout-pre-next-preface ()
(defun allout-pre-next-preface ()
  "Skip forward to just before the next heading line.

Returns that character position."

  (if (re-search-forward allout-line-boundary-regexp nil 'move)
      (prog1 (goto-char (match-beginning 0))
             (allout-prefix-data (match-beginning 2)(match-end 2)))))
;;;_   > allout-end-of-current-subtree ()
(defun allout-end-of-current-subtree ()
  "Put point at the end of the last leaf in the currently visible topic."
  (interactive)
  (allout-back-to-current-heading)
  (let ((level (allout-recent-depth)))
    (allout-next-heading)
    (while (and (not (eobp))
                (> (allout-recent-depth) level))
      (allout-next-heading))
    (and (not (eobp)) (forward-char -1))
    (and (memq (preceding-char) '(?\n ?\^M))
         (memq (aref (buffer-substring (max 1 (- (point) 3)) (point)) 1)
               '(?\n ?\^M))
         (forward-char -1))
    (setq allout-recent-end-of-subtree (point))))
;;;_   > allout-beginning-of-current-entry ()
(defun allout-beginning-of-current-entry ()
  "When not already there, position point at beginning of current topic's body.

If already there, move cursor to bullet for hot-spot operation.
\(See allout-mode doc string for details on hot-spot operation.)"
  (interactive)
  (let ((start-point (point)))
    (allout-end-of-prefix)
    (if (and (interactive-p)
	     (= (point) start-point))
	(goto-char (allout-current-bullet-pos)))))
;;;_   > allout-end-of-current-entry ()
(defun allout-end-of-current-entry ()
  "Position the point at the end of the current topics' entry."
  (interactive)
  (allout-show-entry)
  (prog1 (allout-pre-next-preface)
    (if (and (not (bobp))(looking-at "^$"))
        (forward-char -1))))

;;;_  - Depth-wise
;;;_   > allout-ascend-to-depth (depth)
(defun allout-ascend-to-depth (depth)
  "Ascend to depth DEPTH, returning depth if successful, nil if not."
  (if (and (> depth 0)(<= depth (allout-depth)))
      (let ((last-good (point)))
        (while (and (< depth (allout-depth))
                    (setq last-good (point))
                    (allout-beginning-of-level)
                    (allout-previous-heading)))
        (if (= (allout-recent-depth) depth)
            (progn (goto-char allout-recent-prefix-beginning)
                   depth)
          (goto-char last-good)
          nil))
    (if (interactive-p) (allout-end-of-prefix))))
;;;_   > allout-descend-to-depth (depth)
(defun allout-descend-to-depth (depth)
  "Descend to depth DEPTH within current topic.

Returning depth if successful, nil if not."
  (let ((start-point (point))
        (start-depth (allout-depth)))
    (while
        (and (> (allout-depth) 0)
             (not (= depth (allout-recent-depth))) ; ... not there yet
             (allout-next-heading)     ; ... go further
             (< start-depth (allout-recent-depth)))) ; ... still in topic
    (if (and (> (allout-depth) 0)
             (= (allout-recent-depth) depth))
        depth
      (goto-char start-point)
      nil))
  )
;;;_   > allout-up-current-level (arg &optional dont-complain)
(defun allout-up-current-level (arg &optional dont-complain)
  "Move out ARG levels from current visible topic.

Positions on heading line of containing topic.  Error if unable to
ascend that far, or nil if unable to ascend but optional arg
DONT-COMPLAIN is non-nil."
  (interactive "p")
  (allout-back-to-current-heading)
  (let ((present-level (allout-recent-depth))
	(last-good (point))
	failed
	return)
    ;; Loop for iterating arg:
    (while (and (> (allout-recent-depth) 1)
                (> arg 0)
                (not (bobp))
		(not failed))
      (setq last-good (point))
      ;; Loop for going back over current or greater depth:
      (while (and (not (< (allout-recent-depth) present-level))
		  (or (allout-previous-visible-heading 1)
		      (not (setq failed present-level)))))
      (setq present-level (allout-current-depth))
      (setq arg (- arg 1)))
    (if (or failed
	    (> arg 0))
	(progn (goto-char last-good)
	       (if (interactive-p) (allout-end-of-prefix))
	       (if (not dont-complain)
		   (error "Can't ascend past outermost level.")
		 (if (interactive-p) (allout-end-of-prefix))
		 nil))
      (if (interactive-p) (allout-end-of-prefix))
      allout-recent-prefix-beginning)))

;;;_  - Linear
;;;_   > allout-next-sibling (&optional depth backward)
(defun allout-next-sibling (&optional depth backward)
  "Like allout-forward-current-level, but respects invisible topics.

Traverse at optional DEPTH, or current depth if none specified.

Go backward if optional arg BACKWARD is non-nil.

Return depth if successful, nil otherwise."

  (if (and backward (bobp))
      nil
    (let ((start-depth (or depth (allout-depth)))
          (start-point (point))
	  last-depth)
      (while (and (not (if backward (bobp) (eobp)))
                  (if backward (allout-previous-heading)
                    (allout-next-heading))
                  (> (setq last-depth (allout-recent-depth)) start-depth)))
      (if (and (not (eobp))
               (and (> (or last-depth (allout-depth)) 0)
                    (= (allout-recent-depth) start-depth)))
          allout-recent-prefix-beginning
        (goto-char start-point)
	(if depth (allout-depth) start-depth)
        nil))))
;;;_   > allout-previous-sibling (&optional depth backward)
(defun allout-previous-sibling (&optional depth backward)
  "Like allout-forward-current-level,but backwards & respect invisible topics.

Optional DEPTH specifies depth to traverse, default current depth.

Optional BACKWARD reverses direction.

Return depth if successful, nil otherwise."
  (allout-next-sibling depth (not backward))
  )
;;;_   > allout-snug-back ()
(defun allout-snug-back ()
  "Position cursor at end of previous topic

Presumes point is at the start of a topic prefix."
 (if (or (bobp) (eobp))
     nil
   (forward-char -1))
 (if (or (bobp) (not (memq (preceding-char) '(?\n ?\^M))))
     nil
   (forward-char -1)
   (if (or (bobp) (not (memq (preceding-char) '(?\n ?\^M))))
       (forward-char -1)))
 (point))
;;;_   > allout-beginning-of-level ()
(defun allout-beginning-of-level ()
  "Go back to the first sibling at this level, visible or not."
  (allout-end-of-level 'backward))
;;;_   > allout-end-of-level (&optional backward)
(defun allout-end-of-level (&optional backward)
  "Go to the last sibling at this level, visible or not."

  (let ((depth (allout-depth)))
    (while (allout-previous-sibling depth nil))
    (prog1 (allout-recent-depth)
      (if (interactive-p) (allout-end-of-prefix)))))
;;;_   > allout-next-visible-heading (arg)
(defun allout-next-visible-heading (arg)
  "Move to the next ARG'th visible heading line, backward if arg is negative.

Move as far as possible in indicated direction \(beginning or end of
buffer\) if headings are exhausted."

  (interactive "p")
  (let* ((backward (if (< arg 0) (setq arg (* -1 arg))))
	 (step (if backward -1 1))
	 (start-point (point))
	 prev got)

    (while (> arg 0)			; limit condition
      (while (and (not (if backward (bobp)(eobp))) ; boundary condition
		  ;; Move, skipping over all those concealed lines:
		  (< -1 (forward-line step))
		  (not (setq got (looking-at allout-regexp)))))
      ;; Register this got, it may be the last:
      (if got (setq prev got))
      (setq arg (1- arg)))
    (cond (got				; Last move was to a prefix:
	   (allout-prefix-data (match-beginning 0) (match-end 0))
	   (allout-end-of-prefix))
	  (prev				; Last move wasn't, but prev was:
	   (allout-prefix-data (match-beginning 0) (match-end 0)))
	  ((not backward) (end-of-line) nil))))
;;;_   > allout-previous-visible-heading (arg)
(defun allout-previous-visible-heading (arg)
  "Move to the previous heading line.

With argument, repeats or can move forward if negative.
A heading line is one that starts with a `*' (or that allout-regexp
matches)."
  (interactive "p")
  (allout-next-visible-heading (- arg)))
;;;_   > allout-forward-current-level (arg)
(defun allout-forward-current-level (arg)
  "Position point at the next heading of the same level.

Takes optional repeat-count, goes backward if count is negative.

Returns resulting position, else nil if none found."
  (interactive "p")
  (let ((start-depth (allout-current-depth))
	(start-point (point))
	(start-arg arg)
	(backward (> 0 arg))
	last-depth
	(last-good (point))
	at-boundary)
    (if (= 0 start-depth)
	(error "No siblings, not in a topic..."))
    (if backward (setq arg (* -1 arg)))
    (while (not (or (zerop arg)
		    at-boundary))
      (while (and (not (if backward (bobp) (eobp)))
		  (if backward (allout-previous-visible-heading 1)
		    (allout-next-visible-heading 1))
		  (> (setq last-depth (allout-recent-depth)) start-depth)))
      (if (and last-depth (= last-depth start-depth)
	       (not (if backward (bobp) (eobp))))
	  (setq last-good (point)
		arg (1- arg))
	(setq at-boundary t)))
    (if (and (not (eobp))
	     (= arg 0)
	     (and (> (or last-depth (allout-depth)) 0)
		  (= (allout-recent-depth) start-depth)))
	allout-recent-prefix-beginning
      (goto-char last-good)
      (if (not (interactive-p))
	  nil
	(allout-end-of-prefix)
	(error "Hit %s level %d topic, traversed %d of %d requested."
	       (if backward "first" "last")
	       (allout-recent-depth)
	       (- (abs start-arg) arg)
	       (abs start-arg))))))
;;;_   > allout-backward-current-level (arg)
(defun allout-backward-current-level (arg)
  "Inverse of `allout-forward-current-level'."
  (interactive "p")
  (if (interactive-p)
      (let ((current-prefix-arg (* -1 arg)))
	(call-interactively 'allout-forward-current-level))
    (allout-forward-current-level (* -1 arg))))

;;;_ #5 Alteration

;;;_  - Fundamental
;;;_   > allout-before-change-protect (beg end)
(defun allout-before-change-protect (beg end)
  "Allout before-change hook, regulates changes to concealed text.

Reveal concealed text that would be changed by current command, and
offer user choice to commit or forego the change.  Unchanged text is
reconcealed.  User has option to have changed text reconcealed.

Undo commands are specially treated - the user is not prompted for
choice, the undoes are always committed (based on presumption that the
things being undone were already subject to this regulation routine),
and undoes always leave the changed stuff exposed.

Changes to concealed regions are ignored while file is being written.
\(This is for the sake of functions that do change the file during
writes, like crypt and zip modes.)

Locally bound in allout buffers to `before-change-function', which
in emacs 19 is run before any change to the buffer.  (Has no effect
in Emacs 18, which doesn't support before-change-function.)

Any functions which set [`this-command' to `undo', or which set]
`allout-override-protect' non-nil (as does, eg, allout-flag-chars)
are exempt from this restriction."
  (if (and (allout-mode-p)
					; allout-override-protect
					; set by functions that know what
					; they're doing, eg allout internals:
	   (not allout-override-protect)
	   (not allout-during-write-cue)
	   (save-match-data		; Preserve operation position state.
					; Both beginning and end chars must
					; be exposed:
	     (save-excursion (if (memq this-command '(newline open-line))
				 ;; Compensate for stupid emacs {new,
				 ;; open-}line display optimization:
				 (setq beg (1+ beg)
				       end (1+ end)))
			     (goto-char beg)
			     (or (allout-hidden-p)
				 (and (not (= beg end))
				      (goto-char end)
				      (allout-hidden-p))))))
      (save-match-data
	(if (equal this-command 'undo)
		 ;; Allow undo without inhibition.
		 ;; - Undoing new and open-line hits stupid emacs redisplay
		 ;;   optimization (em 19 cmds.c, ~ line 200).
		 ;; - Presumably, undoing what was properly protected when
		 ;;   done.
		 ;; - Undo may be users' only recourse in protection faults.
		 ;; So, expose what getting changed:
	    (progn (message "Undo! - exposing concealed target...")
		   (if (allout-hidden-p)
		       (allout-show-children))
		   (message "Undo!"))
	  (let (response
		(rehide-completely (save-excursion (allout-goto-prefix)
						   (allout-hidden-p)))
		rehide-place)

	    (save-excursion
	      (if (condition-case err
		      ;; Condition case to catch keyboard quits during reads.
		      (progn
					; Give them a peek where
			(save-excursion
			  (if (eolp) (setq rehide-place
					   (allout-goto-prefix)))
			  (allout-show-entry))
					; Present the message, but...
					; leave the cursor at the location
					; until they respond:
					; Then interpret the response:
			(while
			    (progn
			      (message (concat "Change inside concealed"
					       " region - do it? "
					       "(n or 'y'/'r'eclose)"))
			      (setq response (read-char))
			      (not
			       (cond ((memq response '(?r ?R))
				      (setq response 'reclose))
				     ((memq response '(?y ?Y ? ))
				      (setq response t))
				     ((memq response '(?n ?N 127))
				      (setq response nil)
				      t)
				     ((eq response ??)
				      (message
				       "`r' means `yes, then reclose'")
				      nil)
				     (t (message "Please answer y, n, or r")
					(sit-for 1)
					nil)))))
			response)
		    (quit nil))
					; Continue:
		  (if (eq response 'reclose)
		      (save-excursion
			(if rehide-place (goto-char rehide-place))
			(if rehide-completely
			    (allout-hide-current-entry-completely)
			  (allout-hide-current-entry)))
		    (if (allout-ascend-to-depth (1- (allout-recent-depth)))
			(allout-show-children)
		      (allout-show-to-offshoot)))
					; Prevent:
		(if rehide-completely
		    (save-excursion
		      (if rehide-place (goto-char rehide-place))
		      (allout-hide-current-entry-completely))
		  (allout-hide-current-entry))
		(error (concat
			"Change within concealed region prevented.")))))))
    )	; if
  )	; defun
;;;_   = allout-post-goto-bullet
(defvar allout-post-goto-bullet nil
  "Allout internal var, for `allout-pre-command-business' hot-spot operation.

When set, tells post-processing to reposition on topic bullet, and
then unset it.  Set by allout-pre-command-business when implementing
hot-spot operation, where literal characters typed over a topic bullet
are mapped to the command of the corresponding control-key on the
allout-mode-map.")
(make-variable-buffer-local 'allout-post-goto-bullet)
;;;_   > allout-post-command-business ()
(defun allout-post-command-business ()
  "Allout post-command-hook function.

- Null allout-override-protect, so it's not left open.

- Implement (and clear) allout-post-goto-bullet, for hot-spot
  allout commands.

- Massages buffer-undo-list so successive, standard character self-inserts are
  aggregated.  This kludge compensates for lack of undo bunching when
  before-change-function is used."

					; Apply any external change func:
  (if (not (allout-mode-p))		; In allout-mode.
      nil
    (setq allout-override-protect nil)
    (if allout-during-write-cue
	;; Was used by allout-before-change-protect, done with it now:
	(setq allout-during-write-cue nil))
    ;; Undo bunching business:
    (if (and (listp buffer-undo-list)	; Undo history being kept.
	     (equal this-command 'self-insert-command)
	     (equal last-command 'self-insert-command))
	(let* ((prev-stuff (cdr buffer-undo-list))
	       (before-prev-stuff (cdr (cdr prev-stuff)))
	       cur-cell cur-from cur-to
	       prev-cell prev-from prev-to)
	  (if (and before-prev-stuff	; Goes back far enough to bother,
		   (not (car prev-stuff)) ; and break before current,
		   (not (car before-prev-stuff)) ; !and break before prev!
		   (setq prev-cell (car (cdr prev-stuff))) ; contents now,
		   (setq cur-cell (car buffer-undo-list)) ; contents prev.

		   ;; cur contents denote a single char insertion:
		   (numberp (setq cur-from (car cur-cell)))
		   (numberp (setq cur-to (cdr cur-cell)))
		   (= 1 (- cur-to cur-from))

		   ;; prev contents denote fewer than aggregate-limit
		   ;; insertions:
		   (numberp (setq prev-from (car prev-cell)))
		   (numberp (setq prev-to (cdr prev-cell)))
					; Below threshold:
		   (> allout-undo-aggregation (- prev-to prev-from)))
	      (setq buffer-undo-list
		    (cons (cons prev-from cur-to)
			  (cdr (cdr (cdr buffer-undo-list))))))))
    ;; Implement -post-goto-bullet, if set: (must be after undo business)
    (if (and allout-post-goto-bullet
	     (allout-current-bullet-pos))
	(progn (goto-char (allout-current-bullet-pos))
	       (setq allout-post-goto-bullet nil)))
    ))
;;;_   > allout-pre-command-business ()
(defun allout-pre-command-business ()
  "Allout pre-command-hook function for allout buffers.

Implements special behavior when cursor is on bullet char.

Self-insert characters are reinterpreted control-character references
into the allout-mode-map.  The allout-mode post-command hook will
position a cursor that has moved as a result of such reinterpretation,
on the destination topic's bullet, when the cursor wound up in the

The upshot is that you can get easy, single (unmodified) key allout
maneuvering and general operations by positioning the cursor on the
bullet char, and it continues until you deliberately some non-allout
motion command to relocate the cursor off of a bullet char."

  (if (and (boundp 'allout-mode)
	   allout-mode
	   (eq this-command 'self-insert-command)
	   (eq (point)(allout-current-bullet-pos)))

      (let* ((this-key-num (if (numberp last-command-event)
			       last-command-event))
	     mapped-binding)

					; Map upper-register literals
					; to lower register:
	(if (<= 96 this-key-num)
	    (setq this-key-num (- this-key-num 32)))
					; Check if we have a literal:
	(if (and (<= 64 this-key-num)
		 (>= 96 this-key-num))
	    (setq mapped-binding
		  (lookup-key 'allout-mode-map
			      (concat allout-command-prefix
				      (char-to-string (- this-key-num 64))))))
	(if mapped-binding
	    (setq allout-post-goto-bullet t
		  this-command mapped-binding)))))
;;;_   > allout-find-file-hook ()
(defun allout-find-file-hook ()
  "Activate allout-mode when `allout-auto-activation' & `allout-layout' are non-nil.

See `allout-init' for setup instructions."
  (if (and allout-auto-activation
	   (not (allout-mode-p))
	   allout-layout)
      (allout-mode t)))
;;;_   : Establish the hooks
(add-hook 'post-command-hook 'allout-post-command-business)
(add-hook 'pre-command-hook 'allout-pre-command-business)

;;;_  - Topic Format Assessment
;;;_   > allout-solicit-alternate-bullet (depth &optional current-bullet)
(defun allout-solicit-alternate-bullet (depth &optional current-bullet)

  "Prompt for and return a bullet char as an alternative to the current one.

Offer one suitable for current depth DEPTH as default."

  (let* ((default-bullet (or current-bullet
                             (allout-bullet-for-depth depth)))
	 (sans-escapes (regexp-sans-escapes allout-bullets-string))
	 (choice (solicit-char-in-string
                  (format "Select bullet: %s ('%s' default): "
			  sans-escapes
                          default-bullet)
		  sans-escapes
                  t)))
    (if (string= choice "") default-bullet choice))
  )
;;;_   > allout-sibling-index (&optional depth)
(defun allout-sibling-index (&optional depth)
  "Item number of this prospective topic among its siblings.

If optional arg depth is greater than current depth, then we're
opening a new level, and return 0.

If less than this depth, ascend to that depth and count..."

  (save-excursion
    (cond ((and depth (<= depth 0) 0))
          ((or (not depth) (= depth (allout-depth)))
           (let ((index 1))
             (while (allout-previous-sibling (allout-recent-depth) nil)
	       (setq index (1+ index)))
             index))
          ((< depth (allout-recent-depth))
           (allout-ascend-to-depth depth)
           (allout-sibling-index))
          (0))))
;;;_   > allout-distinctive-bullet (bullet)
(defun allout-distinctive-bullet (bullet)
  "True if bullet is one of those on allout-distinctive-bullets-string."
  (string-match (regexp-quote bullet) allout-distinctive-bullets-string))
;;;_   > allout-numbered-type-prefix (&optional prefix)
(defun allout-numbered-type-prefix (&optional prefix)
  "True if current header prefix bullet is numbered bullet."
  (and allout-numbered-bullet
        (string= allout-numbered-bullet
                 (if prefix
                     (allout-get-prefix-bullet prefix)
                   (allout-get-bullet)))))
;;;_   > allout-bullet-for-depth (&optional depth)
(defun allout-bullet-for-depth (&optional depth)
  "Return allout topic bullet suited to optional DEPTH, or current depth."
  ;; Find bullet in plain-bullets-string modulo DEPTH.
  (if allout-stylish-prefixes
      (char-to-string (aref allout-plain-bullets-string
                            (% (max 0 (- depth 2))
                               allout-plain-bullets-string-len)))
    allout-primary-bullet)
  )

;;;_  - Topic Production
;;;_   > allout-make-topic-prefix (&optional prior-bullet
(defun allout-make-topic-prefix (&optional prior-bullet
                                            new
                                            depth
                                            solicit
                                            number-control
                                            index)
  ;; Depth null means use current depth, non-null means we're either
  ;; opening a new topic after current topic, lower or higher, or we're
  ;; changing level of current topic.
  ;; Solicit dominates specified bullet-char.
;;;_    . Doc string:
  "Generate a topic prefix suitable for optional arg DEPTH, or current depth.

All the arguments are optional.

PRIOR-BULLET indicates the bullet of the prefix being changed, or
nil if none.  This bullet may be preserved (other options
notwithstanding) if it is on the allout-distinctive-bullets-string,
for instance.

Second arg NEW indicates that a new topic is being opened after the
topic at point, if non-nil.  Default bullet for new topics, eg, may
be set (contingent to other args) to numbered bullets if previous
sibling is one.  The implication otherwise is that the current topic
is being adjusted - shifted or rebulleted - and we don't consider
bullet or previous sibling.

Third arg DEPTH forces the topic prefix to that depth, regardless of
the current topics' depth.

Fourth arg SOLICIT non-nil provokes solicitation from the user of a
choice among the valid bullets.  (This overrides other all the
options, including, eg, a distinctive PRIOR-BULLET.)

Fifth arg, NUMBER-CONTROL, matters only if `allout-numbered-bullet'
is non-nil *and* soliciting was not explicitly invoked.  Then
NUMBER-CONTROL non-nil forces prefix to either numbered or
denumbered format, depending on the value of the sixth arg, INDEX.

\(Note that NUMBER-CONTROL does *not* apply to level 1 topics.  Sorry...)

If NUMBER-CONTROL is non-nil and sixth arg INDEX is non-nil then
the prefix of the topic is forced to be numbered.  Non-nil
NUMBER-CONTROL and nil INDEX forces non-numbered format on the
bullet.  Non-nil NUMBER-CONTROL and non-nil, non-number INDEX means
that the index for the numbered prefix will be derived, by counting
siblings back to start of level.  If INDEX is a number, then that
number is used as the index for the numbered prefix (allowing, eg,
sequential renumbering to not require this function counting back the
index for each successive sibling)."
;;;_    . Code:
  ;; The options are ordered in likely frequence of use, most common
  ;; highest, least lowest.  Ie, more likely to be doing prefix
  ;; adjustments than soliciting, and yet more than numbering.
  ;; Current prefix is least dominant, but most likely to be commonly
  ;; specified...

  (let* (body
         numbering
         denumbering
         (depth (or depth (allout-depth)))
         (header-lead allout-header-prefix)
         (bullet-char

          ;; Getting value for bullet char is practically the whole job:

          (cond
                                        ; Simplest situation - level 1:
           ((<= depth 1) (setq header-lead "") allout-primary-bullet)
                                        ; Simple, too: all asterisks:
           (allout-old-style-prefixes
            ;; Cheat - make body the whole thing, null out header-lead and
            ;; bullet-char:
            (setq body (make-string depth
                                    (string-to-char allout-primary-bullet)))
            (setq header-lead "")
            "")

           ;; (Neither level 1 nor old-style, so we're space padding.
           ;; Sneak it in the condition of the next case, whatever it is.)

           ;; Solicitation overrides numbering and other cases:
           ((progn (setq body (make-string (- depth 2) ?\ ))
                   ;; The actual condition:
                   solicit)
            (let* ((got (allout-solicit-alternate-bullet depth)))
              ;; Gotta check whether we're numbering and got a numbered bullet:
              (setq numbering (and allout-numbered-bullet
                                   (not (and number-control (not index)))
                                   (string= got allout-numbered-bullet)))
              ;; Now return what we got, regardless:
              got))

           ;; Numbering invoked through args:
           ((and allout-numbered-bullet number-control)
            (if (setq numbering (not (setq denumbering (not index))))
                allout-numbered-bullet
              (if (and prior-bullet
                       (not (string= allout-numbered-bullet
                                     prior-bullet)))
                  prior-bullet
                (allout-bullet-for-depth depth))))

          ;;; Neither soliciting nor controlled numbering ;;;
             ;;; (may be controlled denumbering, tho) ;;;

           ;; Check wrt previous sibling:
           ((and new				  ; only check for new prefixes
                 (<= depth (allout-depth))
                 allout-numbered-bullet	      ; ... & numbering enabled
                 (not denumbering)
                 (let ((sibling-bullet
                        (save-excursion
                          ;; Locate correct sibling:
                          (or (>= depth (allout-depth))
                              (allout-ascend-to-depth depth))
                          (allout-get-bullet))))
                   (if (and sibling-bullet
                            (string= allout-numbered-bullet sibling-bullet))
                       (setq numbering sibling-bullet)))))

           ;; Distinctive prior bullet?
           ((and prior-bullet
                 (allout-distinctive-bullet prior-bullet)
                 ;; Either non-numbered:
                 (or (not (and allout-numbered-bullet
                               (string= prior-bullet allout-numbered-bullet)))
                     ;; or numbered, and not denumbering:
                     (setq numbering (not denumbering)))
                 ;; Here 'tis:
                 prior-bullet))

           ;; Else, standard bullet per depth:
           ((allout-bullet-for-depth depth)))))

    (concat header-lead
            body
            bullet-char
            (if numbering
                (format "%d" (cond ((and index (numberp index)) index)
                                   (new (1+ (allout-sibling-index depth)))
                                   ((allout-sibling-index))))))
    )
  )
;;;_   > allout-open-topic (relative-depth &optional before)
(defun allout-open-topic (relative-depth &optional before)
  "Open a new topic at depth DEPTH.

New topic is situated after current one, unless optional flag BEFORE
is non-nil, or unless current line is complete empty (not even
whitespace), in which case open is done on current line.

Nuances:

- Creation of new topics is with respect to the visible topic
  containing the cursor, regardless of intervening concealed ones.

- New headers are generally created after/before the body of a
  topic.  However, they are created right at cursor location if the
  cursor is on a blank line, even if that breaks the current topic
  body.  This is intentional, to provide a simple means for
  deliberately dividing topic bodies.

- Double spacing of topic lists is preserved.  Also, the first
  level two topic is created double-spaced (and so would be
  subsequent siblings, if that's left intact).  Otherwise,
  single-spacing is used.

- Creation of sibling or nested topics is with respect to the topic
  you're starting from, even when creating backwards.  This way you
  can easily create a sibling in front of the current topic without
  having to go to its preceding sibling, and then open forward
  from there."

  (let* ((depth (+ (allout-current-depth) relative-depth))
         (opening-on-blank (if (looking-at "^\$")
                               (not (setq before nil))))
         opening-numbered	; Will get while computing ref-topic, below
         ref-depth		; Will get while computing ref-topic, next
         (ref-topic (save-excursion
                      (cond ((< relative-depth 0)
                             (allout-ascend-to-depth depth))
                            ((>= relative-depth 1) nil)
                            (t (allout-back-to-current-heading)))
                      (setq ref-depth (allout-recent-depth))
                      (setq opening-numbered
                            (save-excursion
                              (and allout-numbered-bullet
                                   (or (<= relative-depth 0)
                                       (allout-descend-to-depth depth))
                                   (if (allout-numbered-type-prefix)
                                       allout-numbered-bullet))))
                      (point)))
         dbl-space
         doing-beginning)

    (if (not opening-on-blank)
                                        ; Positioning and vertical
                                        ; padding - only if not
                                        ; opening-on-blank:
        (progn
          (goto-char ref-topic)
          (setq dbl-space               ; Determine double space action:
                (or (and (<= relative-depth 0)	; not descending;
                         (save-excursion
                           ;; at b-o-b or preceded by a blank line?
                           (or (> 0 (forward-line -1))
                               (looking-at "^\\s-*$")
			       (bobp)))
                         (save-excursion
                           ;; succeeded by a blank line?
                           (allout-end-of-current-subtree)
                           (bolp)))
                    (and (= ref-depth 1)
                         (or before
                             (= depth 1)
                             (save-excursion
                               ;; Don't already have following
                               ;; vertical padding:
                               (not (allout-pre-next-preface)))))))

                                        ; Position to prior heading,
                                        ; if inserting backwards, and
					; not going outwards:
          (if (and before (>= relative-depth 0))
	      (progn (allout-back-to-current-heading)
                            (setq doing-beginning (bobp))
                            (if (not (bobp))
                                (allout-previous-heading)))
	    (if (and before (bobp))
		(allout-unprotected (open-line 1))))

          (if (<= relative-depth 0)
              ;; Not going inwards, don't snug up:
              (if doing-beginning
		  (allout-unprotected (open-line (if dbl-space 2 1)))
		(if before
		    (progn (end-of-line)
			   (allout-pre-next-preface)
			   (while (= ?\r (following-char))
                             (forward-char 1))
			   (if (not (looking-at "^$"))
			       (allout-unprotected (open-line 1))))
		  (allout-end-of-current-subtree)))
            ;; Going inwards - double-space if first offspring is,
            ;; otherwise snug up.
            (end-of-line)		; So we skip any concealed progeny.
            (allout-pre-next-preface)
            (if (bolp)
                ;; Blank lines between current header body and next
                ;; header - get to last substantive (non-white-space)
                ;; line in body:
                (re-search-backward "[^ \t\n]" nil t))
            (if (save-excursion
                  (allout-next-heading)
                  (if (> (allout-recent-depth) ref-depth)
                      ;; This is an offspring.
                      (progn (forward-line -1)
                             (looking-at "^\\s-*$"))))
                (progn (forward-line 1)
                       (allout-unprotected (open-line 1))))
            (end-of-line))
          ;;(if doing-beginning (goto-char doing-beginning))
          (if (not (bobp))
              (progn (if (and (not (> depth ref-depth))
                              (not before))
                         (allout-unprotected (open-line 1))
		       (if (> depth ref-depth)
			   (allout-unprotected (newline 1))
			 (if dbl-space
			     (allout-unprotected (open-line 1))
			   (if (not before)
			       (allout-unprotected (newline 1))))))
                     (if dbl-space
			 (allout-unprotected (newline  1)))
                     (if (and (not (eobp))
                              (not (bolp)))
                         (forward-char 1))))
          ))
    (insert-string (concat (allout-make-topic-prefix opening-numbered
                                                      t
                                                      depth)
                           " "))

    ;;(if doing-beginning (save-excursion (newline (if dbl-space 2 1))))


    (allout-rebullet-heading nil		;;; solicit
                              depth 		;;; depth
                              nil 		;;; number-control
                              nil		;;; index
                              t)     (end-of-line)
    )
  )
;;;_    . open-topic contingencies
;;;_     ; base topic - one from which open was issued
;;;_      , beginning char
;;;_      , amount of space before will be used, unless opening in place
;;;_      , end char will be used, unless opening before (and it still may)
;;;_     ; absolute depth of new topic
;;;_     ! insert in place - overrides most stuff
;;;_     ; relative depth of new re base
;;;_     ; before or after base topic
;;;_     ; spacing around topic, if any, prior to new topic and at same depth
;;;_     ; buffer boundaries - special provisions for beginning and end ob
;;;_     ; level 1 topics have special provisions also - double space.
;;;_     ; location of new topic
;;;_    .
;;;_   > allout-open-subtopic (arg)
(defun allout-open-subtopic (arg)
  "Open new topic header at deeper level than the current one.

Negative universal arg means to open deeper, but place the new topic
prior to the current one."
  (interactive "p")
  (allout-open-topic 1 (> 0 arg)))
;;;_   > allout-open-sibtopic (arg)
(defun allout-open-sibtopic (arg)
  "Open new topic header at same level as the current one.

Negative universal arg means to place the new topic prior to the current
one."
  (interactive "p")
  (allout-open-topic 0 (> 0 arg)))
;;;_   > allout-open-supertopic (arg)
(defun allout-open-supertopic (arg)
  "Open new topic header at shallower level than the current one.

Negative universal arg means to open shallower, but place the new
topic prior to the current one."

  (interactive "p")
  (allout-open-topic -1 (> 0 arg)))

;;;_  - Allout Alteration
;;;_   : Topic Modification
;;;_    = allout-former-auto-filler
(defvar allout-former-auto-filler nil
  "Name of modal fill function being wrapped by allout-auto-fill.")
;;;_    > allout-auto-fill ()
(defun allout-auto-fill ()
  "Allout-mode autofill function.

Maintains allout hanging topic indentation if
`allout-use-hanging-indents' is set."
  (let ((fill-prefix (if allout-use-hanging-indents
                         ;; Check for topic header indentation:
                         (save-excursion
                           (beginning-of-line)
                           (if (looking-at allout-regexp)
                               ;; ... construct indentation to account for
                               ;; length of topic prefix:
                               (make-string (progn (allout-end-of-prefix)
                                                   (current-column))
                                            ?\ ))))))
    (if (or allout-former-auto-filler allout-use-hanging-indents)
        (do-auto-fill))))
;;;_    > allout-reindent-body (old-depth new-depth &optional number)
(defun allout-reindent-body (old-depth new-depth &optional number)
  "Reindent body lines which were indented at old-depth to new-depth.

Optional arg NUMBER indicates numbering is being added, and it must
be accommodated.

Note that refill of indented paragraphs is not done."

  (save-excursion
    (allout-end-of-prefix)
    (let* ((new-margin (current-column))
	   excess old-indent-begin old-indent-end
	   curr-ind
	   ;; We want the column where the header-prefix text started
	   ;; *before* the prefix was changed, so we infer it relative
	   ;; to the new margin and the shift in depth:
	   (old-margin (+ old-depth (- new-margin new-depth))))

      ;; Process lines up to (but excluding) next topic header:
      (allout-unprotected
       (save-match-data
         (while
	     (and (re-search-forward "[\n\r]\\(\\s-*\\)"
				     nil
				     t)
		  ;; Register the indent data, before we reset the
		  ;; match data with a subsequent `looking-at':
		  (setq old-indent-begin (match-beginning 1)
			old-indent-end (match-end 1))
		  (not (looking-at allout-regexp)))
	   (if (> 0 (setq excess (- (current-column)
				     old-margin)))
	       ;; Text starts left of old margin - don't adjust:
	       nil
	     ;; Text was hanging at or right of old left margin -
	     ;; reindent it, preserving its existing indentation
	     ;; beyond the old margin:
	     (delete-region old-indent-begin old-indent-end)
	     (indent-to (+ new-margin excess)))))))))
;;;_    > allout-rebullet-current-heading (arg)
(defun allout-rebullet-current-heading (arg)
  "Like non-interactive version `allout-rebullet-heading'.

But \(only\) affects visible heading containing point.

With repeat count, solicit for bullet."
  (interactive "P")
  (save-excursion (allout-back-to-current-heading)
                  (allout-end-of-prefix)
                  (allout-rebullet-heading (not arg)	;;; solicit
                                            nil		;;; depth
                                            nil		;;; number-control
                                            nil		;;; index
                                            t)		;;; do-successors
                  )
  )
;;;_    > allout-rebullet-heading (&optional solicit ...)
(defun allout-rebullet-heading (&optional solicit
                                           new-depth
                                           number-control
                                           index
                                           do-successors)

  "Adjust bullet of current topic prefix.

All args are optional.

If SOLICIT is non-nil then the choice of bullet is solicited from
user.  Otherwise the distinctiveness of the bullet or the topic
depth determines it.

Second arg DEPTH forces the topic prefix to that depth, regardless
of the topics current depth.

Third arg NUMBER-CONTROL can force the prefix to or away from
numbered form.  It has effect only if `allout-numbered-bullet' is
non-nil and soliciting was not explicitly invoked (via first arg).
Its effect, numbering or denumbering, then depends on the setting
of the forth arg, INDEX.

If NUMBER-CONTROL is non-nil and forth arg INDEX is nil, then the
prefix of the topic is forced to be non-numbered.  Null index and
non-nil NUMBER-CONTROL forces denumbering.  Non-nil INDEX (and
non-nil NUMBER-CONTROL) forces a numbered-prefix form.  If non-nil
INDEX is a number, then that number is used for the numbered
prefix.  Non-nil and non-number means that the index for the
numbered prefix will be derived by allout-make-topic-prefix.

Fifth arg DO-SUCCESSORS t means re-resolve count on succeeding
siblings.

Cf vars `allout-stylish-prefixes', `allout-old-style-prefixes',
and `allout-numbered-bullet', which all affect the behavior of
this function."

  (let* ((current-depth (allout-depth))
         (new-depth (or new-depth current-depth))
         (mb allout-recent-prefix-beginning)
         (me allout-recent-prefix-end)
         (current-bullet (buffer-substring (- me 1) me))
         (new-prefix (allout-make-topic-prefix current-bullet
                                                nil
                                                new-depth
                                                solicit
                                                number-control
                                                index)))

    ;; Is new one is identical to old?
    (if (and (= current-depth new-depth)
             (string= current-bullet
                      (substring new-prefix (1- (length new-prefix)))))
	;; Nothing to do:
        t

      ;; New prefix probably different from old:
					; get rid of old one:
      (allout-unprotected (delete-region mb me))
      (goto-char mb)
					; Dispense with number if
					; numbered-bullet prefix:
      (if (and allout-numbered-bullet
               (string= allout-numbered-bullet current-bullet)
               (looking-at "[0-9]+"))
	  (allout-unprotected
	   (delete-region (match-beginning 0)(match-end 0))))

					; Put in new prefix:
      (allout-unprotected (insert-string new-prefix))

      ;; Reindent the body if elected and margin changed:
      (if (and allout-reindent-bodies
	       (not (= new-depth current-depth)))
	  (allout-reindent-body current-depth new-depth))

      ;; Recursively rectify successive siblings of orig topic if
      ;; caller elected for it:
      (if do-successors
	  (save-excursion
	    (while (allout-next-sibling new-depth nil)
	      (setq index
		    (cond ((numberp index) (1+ index))
			  ((not number-control)  (allout-sibling-index))))
	      (if (allout-numbered-type-prefix)
		  (allout-rebullet-heading nil		;;; solicit
					    new-depth	;;; new-depth
					    number-control;;; number-control
					    index	;;; index
					    nil)))))	;;;(dont!)do-successors
      )	; (if (and (= current-depth new-depth)...))
    ) ; let* ((current-depth (allout-depth))...)
  ) ; defun
;;;_    > allout-rebullet-topic (arg)
(defun allout-rebullet-topic (arg)
  "Like allout-rebullet-topic-grunt, but start from topic visible at point.

Descends into invisible as well as visible topics, however.

With repeat count, shift topic depth by that amount."
  (interactive "P")
  (let ((start-col (current-column))
        (was-eol (eolp)))
    (save-excursion
      ;; Normalize arg:
      (cond ((null arg) (setq arg 0))
            ((listp arg) (setq arg (car arg))))
      ;; Fill the user in, in case we're shifting a big topic:
      (if (not (zerop arg)) (message "Shifting..."))
      (allout-back-to-current-heading)
      (if (<= (+ (allout-recent-depth) arg) 0)
          (error "Attempt to shift topic below level 1"))
      (allout-rebullet-topic-grunt arg)
      (if (not (zerop arg)) (message "Shifting... done.")))
    (move-to-column (max 0 (+ start-col arg)))))
;;;_     > allout-rebullet-topic-grunt (&optional relative-depth ...)
(defun allout-rebullet-topic-grunt (&optional relative-depth
                                               starting-depth
                                               starting-point
                                               index
                                               do-successors)

  "Rebullet the topic at point, visible or invisible, and all
contained subtopics.  See allout-rebullet-heading for rebulleting
behavior.

All arguments are optional.

First arg RELATIVE-DEPTH means to shift the depth of the entire
topic that amount.

The rest of the args are for internal recursive use by the function
itself.  The are STARTING-DEPTH, STARTING-POINT, and INDEX."

  (let* ((relative-depth (or relative-depth 0))
         (new-depth (allout-depth))
         (starting-depth (or starting-depth new-depth))
         (on-starting-call  (null starting-point))
         (index (or index
                    ;; Leave index null on starting call, so rebullet-heading
                    ;; calculates it at what might be new depth:
                    (and (or (zerop relative-depth)
                             (not on-starting-call))
                         (allout-sibling-index))))
         (moving-outwards (< 0 relative-depth))
         (starting-point (or starting-point (point))))

    ;; Sanity check for excessive promotion done only on starting call:
    (and on-starting-call
         moving-outwards
         (> 0 (+ starting-depth relative-depth))
         (error "Attempt to shift topic out beyond level 1."))	;;; ====>

    (cond ((= starting-depth new-depth)
           ;; We're at depth to work on this one:
           (allout-rebullet-heading nil		;;; solicit
                                     (+ starting-depth	;;; starting-depth
                                        relative-depth)
                                     nil		;;; number
                                     index		;;; index
                                     ;; Every contained topic will get hit,
                                     ;; and we have to get to outside ones
                                     ;; deliberately:
                                     nil)		;;; do-successors
           ;; ... and work on subsequent ones which are at greater depth:
           (setq index 0)
           (allout-next-heading)
           (while (and (not (eobp))
                       (< starting-depth (allout-recent-depth)))
             (setq index (1+ index))
             (allout-rebullet-topic-grunt relative-depth   ;;; relative-depth
                                           (1+ starting-depth);;;starting-depth
                                           starting-point   ;;; starting-point
                                           index)))	    ;;; index

          ((< starting-depth new-depth)
           ;; Rare case - subtopic more than one level deeper than parent.
           ;; Treat this one at an even deeper level:
           (allout-rebullet-topic-grunt relative-depth   ;;; relative-depth
                                         new-depth	  ;;; starting-depth
                                         starting-point	  ;;; starting-point
                                         index)))	  ;;; index

    (if on-starting-call
        (progn
          ;; Rectify numbering of former siblings of the adjusted topic,
          ;; if topic has changed depth
          (if (or do-successors
                  (and (not (zerop relative-depth))
                       (or (= (allout-recent-depth) starting-depth)
                           (= (allout-recent-depth) (+ starting-depth
                                                        relative-depth)))))
              (allout-rebullet-heading nil nil nil nil t))
          ;; Now rectify numbering of new siblings of the adjusted topic,
          ;; if depth has been changed:
          (progn (goto-char starting-point)
                 (if (not (zerop relative-depth))
                     (allout-rebullet-heading nil nil nil nil t)))))
    )
  )
;;;_    > allout-renumber-to-depth (&optional depth)
(defun allout-renumber-to-depth (&optional depth)
  "Renumber siblings at current depth.

Affects superior topics if optional arg DEPTH is less than current depth.

Returns final depth."

  ;; Proceed by level, processing subsequent siblings on each,
  ;; ascending until we get shallower than the start depth:

  (let ((ascender (allout-depth)))
    (while (and (not (eobp))
		(allout-depth)
                (>= (allout-recent-depth) depth)
                (>= ascender depth))
                                        ; Skip over all topics at
                                        ; lesser depths, which can not
                                        ; have been disturbed:
      (while (and (not (eobp))
		  (> (allout-recent-depth) ascender))
        (allout-next-heading))
                                        ; Prime ascender for ascension:
      (setq ascender (1- (allout-recent-depth)))
      (if (>= (allout-recent-depth) depth)
          (allout-rebullet-heading nil	;;; solicit
                                    nil	;;; depth
                                    nil	;;; number-control
                                    nil	;;; index
                                    t))));;; do-successors
  (allout-recent-depth))
;;;_    > allout-number-siblings (&optional denumber)
(defun allout-number-siblings (&optional denumber)
  "Assign numbered topic prefix to this topic and its siblings.

With universal argument, denumber - assign default bullet to this
topic and its siblings.

With repeated universal argument (`^U^U'), solicit bullet for each
rebulleting each topic at this level."

  (interactive "P")

  (save-excursion
    (allout-back-to-current-heading)
    (allout-beginning-of-level)
    (let ((depth (allout-recent-depth))
	  (index (if (not denumber) 1))
          (use-bullet (equal '(16) denumber))
          (more t))
      (while more
        (allout-rebullet-heading use-bullet		;;; solicit
                                  depth			;;; depth
                                  t			;;; number-control
                                  index			;;; index
                                  nil)			;;; do-successors
        (if index (setq index (1+ index)))
        (setq more (allout-next-sibling depth nil))))))
;;;_    > allout-shift-in (arg)
(defun allout-shift-in (arg)
  "Increase depth of current heading and any topics collapsed within it."
  (interactive "p")
  (allout-rebullet-topic arg))
;;;_    > allout-shift-out (arg)
(defun allout-shift-out (arg)
  "Decrease depth of current heading and any topics collapsed within it."
  (interactive "p")
  (allout-rebullet-topic (* arg -1)))
;;;_   : Surgery (kill-ring) functions with special provisions for outlines:
;;;_    > allout-kill-line (&optional arg)
(defun allout-kill-line (&optional arg)
  "Kill line, adjusting subsequent lines suitably for allout mode."

  (interactive "*P")
  (if (not (and (allout-mode-p)		; active allout mode,
		allout-numbered-bullet		; numbers may need adjustment,
		(bolp)				; may be clipping topic head,
		(looking-at allout-regexp)))	; are clipping topic head.
      ;; Above conditions do not obtain - just do a regular kill:
      (kill-line arg)
    ;; Ah, have to watch out for adjustments:
    (let* ((depth (allout-depth)))
                                        ; Do the kill:
      (kill-line arg)
                                        ; Provide some feedback:
      (sit-for 0)
      (save-excursion
                                        ; Start with the topic
                                        ; following killed line:
        (if (not (looking-at allout-regexp))
            (allout-next-heading))
        (allout-renumber-to-depth depth)))))
;;;_    > allout-kill-topic ()
(defun allout-kill-topic ()
  "Kill topic together with subtopics.

Leaves primary topic's trailing vertical whitespace, if any."

  ;; Some finagling is done to make complex topic kills appear faster
  ;; than they actually are.  A redisplay is performed immediately
  ;; after the region is disposed of, though the renumbering process
  ;; has yet to be performed.  This means that there may appear to be
  ;; a lag *after* the kill has been performed.

  (interactive)
  (let* ((beg (prog1 (allout-back-to-current-heading)(beginning-of-line)))
         (depth (allout-recent-depth)))
    (allout-end-of-current-subtree)
    (if (not (eobp))
	(if (or (not (looking-at "^$"))
		;; A blank line - cut it with this topic *unless* this
		;; is the last topic at this level, in which case
		;; we'll leave the blank line as part of the
		;; containing topic:
		(save-excursion
		  (and (allout-next-heading)
		       (>= (allout-recent-depth) depth))))
	    (forward-char 1)))

    (kill-region beg (point))
    (sit-for 0)
    (save-excursion
      (allout-renumber-to-depth depth))))
;;;_    > allout-yank-processing ()
(defun allout-yank-processing (&optional arg)

  "Incidental allout-specific business to be done just after text yanks.

Does depth adjustment of yanked topics, when:

1 the stuff being yanked starts with a valid allout header prefix, and
2 it is being yanked at the end of a line which consists of only a valid
     topic prefix.

Also, adjusts numbering of subsequent siblings when appropriate.

Depth adjustment alters the depth of all the topics being yanked
the amount it takes to make the first topic have the depth of the
header into which it's being yanked.

The point is left in front of yanked, adjusted topics, rather than
at the end (and vice-versa with the mark).  Non-adjusted yanks,
however, are left exactly like normal, non-allout-specific yanks."

  (interactive "*P")
					; Get to beginning, leaving
					; region around subject:
  (if (< (mark-marker) (point))
      (exchange-point-and-mark))
  (let* ((subj-beg (point))
	 (subj-end (mark-marker))
	 ;; `resituate' if yanking an entire topic into topic header:
	 (resituate (and (allout-e-o-prefix-p)
			 (looking-at (concat "\\(" allout-regexp "\\)"))
			 (allout-prefix-data (match-beginning 1)
					      (match-end 1))))
	 ;; `rectify-numbering' if resituating (where several topics may
	 ;; be resituating) or yanking a topic into a topic slot (bol):
	 (rectify-numbering (or resituate
				(and (bolp) (looking-at allout-regexp)))))
    (if resituate
                                        ; The yanked stuff is a topic:
	(let* ((prefix-len (- (match-end 1) subj-beg))
	       (subj-depth (allout-recent-depth))
	       (prefix-bullet (allout-recent-bullet))
	       (adjust-to-depth
		;; Nil if adjustment unnecessary, otherwise depth to which
		;; adjustment should be made:
		(save-excursion
		  (and (goto-char subj-end)
		       (eolp)
		       (goto-char subj-beg)
		       (and (looking-at allout-regexp)
			    (progn
			      (beginning-of-line)
			      (not (= (point) subj-beg)))
			    (looking-at allout-regexp)
			    (allout-prefix-data (match-beginning 0)
						 (match-end 0)))
		       (allout-recent-depth))))
	       done
	       (more t))
	  (setq rectify-numbering allout-numbered-bullet)
	  (if adjust-to-depth
                                        ; Do the adjustment:
	      (progn
		(message "... yanking") (sit-for 0)
		(save-restriction
		  (narrow-to-region subj-beg subj-end)
                                        ; Trim off excessive blank
                                        ; line at end, if any:
		  (goto-char (point-max))
		  (if (looking-at "^$")
		      (allout-unprotected (delete-char -1)))
                                        ; Work backwards, with each
                                        ; shallowest level,
                                        ; successively excluding the
                                        ; last processed topic from
                                        ; the narrow region:
		  (while more
		    (allout-back-to-current-heading)
                                        ; go as high as we can in each bunch:
		    (while (allout-ascend-to-depth (1- (allout-depth))))
		    (save-excursion
		      (allout-rebullet-topic-grunt (- adjust-to-depth
						       subj-depth))
		      (allout-depth))
		    (if (setq more (not (bobp)))
			(progn (widen)
			       (forward-char -1)
			       (narrow-to-region subj-beg (point))))))
		(message "")
		;; Preserve new bullet if it's a distinctive one, otherwise
		;; use old one:
		(if (string-match (regexp-quote prefix-bullet)
				  allout-distinctive-bullets-string)
                                        ; Delete from bullet of old to
                                        ; before bullet of new:
		    (progn
		      (beginning-of-line)
		      (delete-region (point) subj-beg)
		      (set-marker (mark-marker) subj-end)
		      (goto-char subj-beg)
		      (allout-end-of-prefix))
                                        ; Delete base subj prefix,
                                        ; leaving old one:
		  (delete-region (point) (+ (point)
					    prefix-len
					    (- adjust-to-depth subj-depth)))
                                        ; and delete residual subj
                                        ; prefix digits and space:
		  (while (looking-at "[0-9]") (delete-char 1))
		  (if (looking-at " ") (delete-char 1))))
	    (exchange-point-and-mark))))
    (if rectify-numbering
	(progn
	  (save-excursion
                                        ; Give some preliminary feedback:
	    (message "... reconciling numbers") (sit-for 0)
                                        ; ... and renumber, in case necessary:
	    (goto-char subj-beg)
	    (if (allout-goto-prefix)
		(allout-rebullet-heading nil	;;; solicit
					  (allout-depth) ;;; depth
					  nil	;;; number-control
					  nil	;;; index
					  t))
	    (message ""))))
    (if (not resituate)
      (exchange-point-and-mark))))
;;;_    > allout-yank (&optional arg)
(defun allout-yank (&optional arg)
  "Allout-mode yank, with depth and numbering adjustment of yanked topics.

Non-topic yanks work no differently than normal yanks.

If a topic is being yanked into a bare topic prefix, the depth of the
yanked topic is adjusted to the depth of the topic prefix.

  1 we're yanking in an allout-mode buffer
  2 the stuff being yanked starts with a valid allout header prefix, and
  3 it is being yanked at the end of a line which consists of only a valid
    topic prefix.

If these conditions hold then the depth of the yanked topics are all
adjusted the amount it takes to make the first one at the depth of the
header into which it's being yanked.

The point is left in front of yanked, adjusted topics, rather than
at the end (and vice-versa with the mark).  Non-adjusted yanks,
however, (ones that don't qualify for adjustment) are handled
exactly like normal yanks.

Numbering of yanked topics, and the successive siblings at the depth
into which they're being yanked, is adjusted.

Allout-yank-pop works with allout-yank just like normal yank-pop
works with normal yank in non-allout buffers."

  (interactive "*P")
  (setq this-command 'yank)
  (yank arg)
  (if (allout-mode-p)
      (allout-yank-processing)))
;;;_    > allout-yank-pop (&optional arg)
(defun allout-yank-pop (&optional arg)
  "Yank-pop like allout-yank when popping to bare allout prefixes.

Adapts level of popped topics to level of fresh prefix.

Note - prefix changes to distinctive bullets will stick, if followed
by pops to non-distinctive yanks.  Bug..."

  (interactive "*p")
  (setq this-command 'yank)
  (yank-pop arg)
  (if (allout-mode-p)
      (allout-yank-processing)))

;;;_  - Specialty bullet functions
;;;_   : File Cross references
;;;_    > allout-resolve-xref ()
(defun allout-resolve-xref ()
  "Pop to file associated with current heading, if it has an xref bullet.

\(Works according to setting of `allout-file-xref-bullet')."
  (interactive)
  (if (not allout-file-xref-bullet)
      (error
       "allout cross references disabled - no `allout-file-xref-bullet'")
    (if (not (string= (allout-current-bullet) allout-file-xref-bullet))
        (error "current heading lacks cross-reference bullet `%s'"
               allout-file-xref-bullet)
      (let (file-name)
        (save-excursion
          (let* ((text-start allout-recent-prefix-end)
                 (heading-end (progn (end-of-line) (point))))
            (goto-char text-start)
            (setq file-name
                  (if (re-search-forward "\\s-\\(\\S-*\\)" heading-end t)
                      (buffer-substring (match-beginning 1) (match-end 1))))))
        (setq file-name
              (if (not (= (aref file-name 0) ?:))
                  (expand-file-name file-name)
                                        ; A registry-files ref, strip the `:'
                                        ; and try to follow it:
                (let ((reg-ref (reference-registered-file
                                (substring file-name 1) nil t)))
                  (if reg-ref (car (cdr reg-ref))))))
        (if (or (file-exists-p file-name)
                (if (file-writable-p file-name)
                    (y-or-n-p (format "%s not there, create one? "
                                      file-name))
                  (error "%s not found and can't be created" file-name)))
            (condition-case failure
                (find-file-other-window file-name)
              (error failure))
          (error "%s not found" file-name))
        )
      )
    )
  )

;;;_ #6 Exposure Control and Processing

;;;_  - Fundamental
;;;_   > allout-flag-region (from to flag)
(defmacro allout-flag-region (from to flag)
  "Hide or show lines from FROM to TO, via emacs selective-display FLAG char.
Ie, text following flag C-m \(carriage-return) is hidden until the
next C-j (newline) char.

Returns the endpoint of the region."
  (` (let ((buffer-read-only nil)
	   (allout-override-protect t))
       (subst-char-in-region (, from) (, to)
			     (if (= (, flag) ?\n) ?\r ?\n)
			     (, flag) t))))
;;;_   > allout-flag-current-subtree (flag)
(defun allout-flag-current-subtree (flag)
  "Hide or show subtree of currently-visible topic.

See `allout-flag-region' for more details."

  (save-excursion
    (allout-back-to-current-heading)
    (allout-flag-region (point)
			 (progn (allout-end-of-current-subtree) (1- (point)))
			 flag)))

;;;_  - Mapping and processing of topics
;;;_   " See also chart functions, in navigation
;;;_   > allout-listify-exposed (&optional start end)
(defun allout-listify-exposed (&optional start end)

  "Produce a list representing exposed topics in current region.

This list can then be used by `allout-process-exposed' to manipulate
the subject region.

List is composed of elements that may themselves be lists representing
exposed components in subtopic.

Each component list contains:
 - a number representing the depth of the topic,
 - a string representing the header-prefix (ref. `allout-header-prefix'),
 - a string representing the bullet character,
 - and a series of strings, each containing one line of the exposed
   portion of the topic entry."

  (interactive "r")
  (save-excursion
    (let* (strings pad result depth bullet beg next done) ; State vars.
      (goto-char start)
      (beginning-of-line)
      (if (not (allout-goto-prefix))	; Get initial position within a topic:
	  (allout-next-visible-heading 1))
      (while (and (not done)
		  (not (eobp))		; Loop until we've covered the region.
		  (not (> (point) end)))
	(setq depth (allout-recent-depth) 	; Current topics' depth,
	      bullet (allout-recent-bullet)	; ... bullet,
	      beg (progn (allout-end-of-prefix t) (point))) ; and beginning.
	(setq done			; The boundary for the current topic:
	      (not (allout-next-visible-heading 1)))
	(beginning-of-line)
	(setq next (point))
	(goto-char beg)
	(setq strings nil)
	(while (> next (point))		; Get all the exposed text in
	  (setq strings
		(cons (buffer-substring
		       beg
					;To hidden text or end of line:
		       (progn
			 (search-forward "\r"
					 (save-excursion (end-of-line)
							 (point))
					 1)
			 (if (= (preceding-char) ?\r)
			     (1- (point))
			   (point))))
		      strings))
	  (if (< (point) next)		; Resume from after hid text, if any.
	      (forward-line 1))
	  (setq beg (point)))
	;; Accumulate list for this topic:
	(setq result
	      (cons (append (list depth
				  allout-header-prefix
				  bullet)
			    (nreverse strings))
		    result)))
      ;; Put the list with first at front, to last at back:
      (nreverse result))))
;;;_   > allout-process-exposed (arg &optional tobuf)
(defun allout-process-exposed (&optional func from to frombuf tobuf)
  "Map function on exposed parts of current topic; results to another buffer.

Apply FUNCTION \(default 'allout-insert-listified) to exposed
portions FROM position TO position \(default region, or the entire
buffer if no region active) in buffer FROMBUF \(default current
buffer) to buffer TOBUF \(default is buffer named like frombuf but
with \"*\" prepended and \" exposed*\" appended).

The function must as its arguments the elements of the list
representations of topic entries produced by allout-listify-exposed."

					; Resolve arguments,
					; defaulting if necessary:
  (if (not func) (setq func 'allout-insert-listified))
  (if (not (and from to))
      (if mark-active
	  (setq from (region-beginning) to (region-end))
	(setq from (point-min) to (point-max))))
  (if frombuf
      (if (not (bufferp frombuf))
	  ;; Specified but not a buffer - get it:
	  (let ((got (get-buffer frombuf)))
	    (if (not got)
		(error "allout-process-exposed: source buffer %s not found."
		       frombuf)
	      (setq frombuf got))))
    ;; not specified - default it:
    (setq frombuf (current-buffer)))
  (if tobuf
      (if (not (bufferp tobuf))
	  (setq tobuf (get-buffer-create tobuf)))
    ;; not specified - default it:
    (setq tobuf (concat "*" (buffer-name frombuf) " exposed*")))

  (let* ((listified (progn (set-buffer frombuf)
			   (allout-listify-exposed from to)))
	 (prefix allout-header-prefix)	; ... as set in frombuf.
	 curr)
    (set-buffer tobuf)
    (while listified
      (setq curr (car listified))
      (setq listified (cdr listified))
      (apply func (list (car curr)			; depth
			(car (cdr curr))		; header-prefix
			(car (cdr (cdr curr)))		; bullet
			(cdr (cdr (cdr curr))))))	; list of text lines
    (pop-to-buffer tobuf)))

;;;_  - Topic-specific
;;;_   > allout-show-entry ()
; allout-show-entry basically for isearch dynamic exposure, as is...
(defun allout-show-entry ()
  "Like `allout-show-current-entry', reveals entries nested in hidden topics.

This is a way to give restricted peek at a concealed locality without the
expense of exposing its context, but can leave the allout with aberrant
exposure.  allout-hide-current-entry-completely or allout-show-offshoot
should be used after the peek to rectify the exposure."

  (interactive)
  (save-excursion
    (allout-goto-prefix)
    (allout-flag-region (if (bobp) (point) (1- (point)))
                         (or (allout-pre-next-preface) (point))
			 ?\n)))
;;;_   > allout-show-children (&optional level strict)
(defun allout-show-children (&optional level strict)

  "If point is visible, show all direct subheadings of this heading.

Otherwise, do allout-show-to-offshoot, and then show subheadings.

Optional LEVEL specifies how many levels below the current level
should be shown, or all levels if t.  Default is 1.

Optional STRICT means don't resort to -show-to-offshoot, no matter
what.  This is basically so -show-to-offshoot, which is called by
this function, can employ the pure offspring-revealing capabilities of
it.

Returns point at end of subtree that was opened, if any.  (May get a
point of non-opened subtree?)"

  (interactive "p")
  (let (max-pos)
    (if (and (not strict)
	     (allout-hidden-p))

	(progn (allout-show-to-offshoot) ; Point's concealed, open to
					  ; expose it.
	       ;; Then recurse, but with "strict" set so we don't
	       ;; infinite regress:
	       (setq max-pos (allout-show-children level t)))

      (save-excursion
	(save-restriction
	  (let* ((start-pt (point))
		 (chart (allout-chart-subtree (or level 1)))
		 (to-reveal (allout-chart-to-reveal chart (or level 1))))
	    (goto-char start-pt)
	    (if (and strict (= (preceding-char) ?\r))
		;; Concealed root would already have been taken care of,
		;; unless strict was set.
		(allout-flag-region (point) (allout-snug-back) ?\n))
	    (while to-reveal
	      (goto-char (car to-reveal))
	      (allout-flag-region (point) (allout-snug-back) ?\n)
	      (setq to-reveal (cdr to-reveal)))))))))
;;;_   x allout-show-current-children (&optional level strict)
(defun allout-show-current-children (&optional level strict)
  "This command was misnamed, use `allout-show-children' instead.

\(The \"current\" in the name is supposed to imply that it works on
the visible topic containing point, while it really works with respect
to the most immediate topic, concealed or not.  I'll leave this old
name around for a bit, but i'll soon activate an annoying message to
warn people about the change, and then deprecate this alias."

  (interactive "p")
  ;;(beep)
  ;;(message (format "Use `%s' instead of `%s' (%s)."
  ;;		   "allout-show-children"
  ;;		   "allout-show-current-children"
  ;;		   (buffer-name (current-buffer))))
  (allout-show-children level strict))
;;;_   > allout-hide-point-reconcile ()
(defun allout-hide-reconcile ()
  "Like `allout-hide-current-entry'; hides completely if within hidden region.

Specifically intended for aberrant exposure states, like entries that were
exposed by allout-show-entry but are within otherwise concealed regions."
  (interactive)
  (save-excursion
    (allout-goto-prefix)
    (allout-flag-region (if (not (bobp)) (1- (point)) (point))
                         (progn (allout-pre-next-preface)
                                (if (= ?\r (following-char))
                                    (point)
                                  (1- (point))))
                         ?\r)))
;;;_   > allout-show-to-offshoot ()
(defun allout-show-to-offshoot ()
  "Like allout-show-entry, but reveals opens all concealed ancestors, as well.

As with allout-hide-current-entry-completely, useful for rectifying
aberrant exposure states produced by allout-show-entry."

  (interactive)
  (save-excursion
    (let ((orig-pt (point))
	  (orig-pref (allout-goto-prefix))
	  (last-at (point))
	  bag-it)
      (while (or bag-it (= (preceding-char) ?\r))
	(beginning-of-line)
	(if (= last-at (setq last-at (point)))
	    ;; Oops, we're not making any progress!  Show the current
	    ;; topic completely, and bag this try.
	    (progn (beginning-of-line)
		   (allout-show-current-subtree)
		   (goto-char orig-pt)
		   (setq bag-it t)
		   (beep)
		   (message "%s: %s"
			    "allout-show-to-offshoot: "
			    "Aberrant nesting encountered.")))
	(allout-show-children)
	(goto-char orig-pref))
      (goto-char orig-pt)))
  (if (allout-hidden-p)
      (allout-show-entry)))
;;;_   > allout-hide-current-entry ()
(defun allout-hide-current-entry ()
  "Hide the body directly following this heading."
  (interactive)
  (allout-back-to-current-heading)
  (save-excursion
   (allout-flag-region (point)
                        (progn (allout-end-of-current-entry) (point))
                        ?\^M)))
;;;_   > allout-show-current-entry (&optional arg)
(defun allout-show-current-entry (&optional arg)

  "Show body following current heading, or hide the entry if repeat count."

  (interactive "P")
  (if arg
      (allout-hide-current-entry)
    (save-excursion
      (allout-flag-region (point)
			   (progn (allout-end-of-current-entry) (point))
			   ?\n))))
;;;_   > allout-hide-current-entry-completely ()
; ... allout-hide-current-entry-completely also for isearch dynamic exposure:
(defun allout-hide-current-entry-completely ()
  "Like allout-hide-current-entry, but conceal topic completely.

Specifically intended for aberrant exposure states, like entries that were
exposed by allout-show-entry but are within otherwise concealed regions."
  (interactive)
  (save-excursion
    (allout-goto-prefix)
    (allout-flag-region (if (not (bobp)) (1- (point)) (point))
                         (progn (allout-pre-next-preface)
                                (if (= ?\r (following-char))
                                    (point)
                                  (1- (point))))
                         ?\r)))
;;;_   > allout-show-current-subtree (&optional arg)
(defun allout-show-current-subtree (&optional arg)
  "Show everything within the current topic.  With a repeat-count,
expose this topic and its siblings."
  (interactive "P")
  (save-excursion
    (if (<= (allout-current-depth) 0)
	;; Outside any topics - try to get to the first:
	(if (not (allout-next-heading))
	    (error "No topics.")
	  ;; got to first, outermost topic - set to expose it and siblings:
	  (message "Above outermost topic - exposing all.")
	  (allout-flag-region (point-min)(point-max) ?\n))
      (if (not arg)
	  (allout-flag-current-subtree ?\n)
	(allout-beginning-of-level)
	(allout-expose-topic '(* :))))))
;;;_   > allout-hide-current-subtree (&optional just-close)
(defun allout-hide-current-subtree (&optional just-close)
  "Close the current topic, or containing topic if this one is already closed.

If this topic is closed and it's a top level topic, close this topic
and its siblings.

If optional arg JUST-CLOSE is non-nil, do not treat the parent or
siblings, even if the target topic is already closed."

  (interactive)
  (let ((from (point))
	(orig-eol (progn (end-of-line)
			 (if (not (allout-goto-prefix))
			     (error "No topics found.")
			   (end-of-line)(point)))))
    (allout-flag-current-subtree ?\^M)
    (goto-char from)
    (if (and (= orig-eol (progn (goto-char orig-eol)
				(end-of-line)
				(point)))
	     (not just-close)
             ;; Structure didn't change - try hiding current level:
	     (goto-char from)
	     (if (allout-up-current-level 1 t)
		 t
	       (goto-char 0)
	       (let ((msg
		      "Top-level topic already closed - closing siblings..."))
		 (message msg)
		 (allout-expose-topic '(0 :))
		 (message (concat msg "  Done.")))
	       nil)
	     (/= (allout-recent-depth) 0))
	(allout-hide-current-subtree))
      (goto-char from)))
;;;_   > allout-show-current-branches ()
(defun allout-show-current-branches ()
  "Show all subheadings of this heading, but not their bodies."
  (interactive)
  (beginning-of-line)
  (allout-show-children t))
;;;_   > allout-hide-current-leaves ()
(defun allout-hide-current-leaves ()
  "Hide the bodies of the current topic and all its offspring."
  (interactive)
  (allout-back-to-current-heading)
  (allout-hide-region-body (point) (progn (allout-end-of-current-subtree)
                                           (point))))

;;;_  - Region and beyond
;;;_   > allout-show-all ()
(defun allout-show-all ()
  "Show all of the text in the buffer."
  (interactive)
  (message "Exposing entire buffer...")
  (allout-flag-region (point-min) (point-max) ?\n)
  (message "Exposing entire buffer...  Done."))
;;;_   > allout-hide-bodies ()
(defun allout-hide-bodies ()
  "Hide all of buffer except headings."
  (interactive)
  (allout-hide-region-body (point-min) (point-max)))
;;;_   > allout-hide-region-body (start end)
(defun allout-hide-region-body (start end)
  "Hide all body lines in the region, but not headings."
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (not (eobp))
	(allout-flag-region (point)
                             (progn (allout-pre-next-preface) (point)) ?\^M)
	(if (not (eobp))
	    (forward-char
	     (if (looking-at "[\n\r][\n\r]")
		 2 1)))))))

;;;_   > allout-expose-topic (spec)
(defun allout-expose-topic (spec)
  "Apply exposure specs to successive allout topic items.

Use the more convenient frontend, `allout-new-exposure', if you don't
need evaluation of the arguments, or even better, the `allout-layout'
variable-keyed mode-activation/auto-exposure feature of allout allout
mode.  See the respective documentation strings for more details.

Cursor is left at start position.

SPEC is either a number or a list.

Successive specs on a list are applied to successive sibling topics.

A simple spec \(either a number, one of a few symbols, or the null
list) dictates the exposure for the corresponding topic.

Non-null lists recursively designate exposure specs for respective
subtopics of the current topic.

The `:' repeat spec is used to specify exposure for any number of
successive siblings, up to the trailing ones for which there are
explicit specs following the `:'.

Simple (numeric and null-list) specs are interpreted as follows:

 Numbers indicate the relative depth to open the corresponding topic.
     - negative numbers force the topic to be closed before opening to the
       absolute value of the number, so all siblings are open only to
       that level.
     - positive numbers open to the relative depth indicated by the
       number, but do not force already opened subtopics to be closed.
     - 0 means to close topic - hide all offspring.
  :  - `repeat'
       apply prior element to all siblings at current level, *up to*
       those siblings that would be covered by specs following the `:'
       on the list.  Ie, apply to all topics at level but the last
       ones.  \(Only first of multiple colons at same level is
       respected - subsequent ones are discarded.)
  *  - completely opens the topic, including bodies.
  +  - shows all the sub headers, but not the bodies
  -  - exposes the body of the corresponding topic.

Examples:
\(allout-expose-topic '(-1 : 0))
	Close this and all following topics at current level, exposing
	only their immediate children, but close down the last topic
	at this current level completely.
\(allout-expose-topic '(-1 () : 1 0))
	Close current topic so only the immediate subtopics are shown;
	show the children in the second to last topic, and completely
	close the last one.
\(allout-expose-topic '(-2 : -1 *))
        Expose children and grandchildren of all topics at current
	level except the last two; expose children of the second to
	last and completely open the last one."

  (interactive "xExposure spec: ")
  (if (not (listp spec))
      nil
    (let ((depth (allout-depth))
	  (max-pos 0)
	  prev-elem curr-elem
	  stay done
	  snug-back
	  )
      (while spec
	(setq prev-elem curr-elem
	      curr-elem (car spec)
	      spec (cdr spec))
	(cond				; Do current element:
	 ((null curr-elem) nil)
	 ((symbolp curr-elem)
	  (cond ((eq curr-elem '*) (allout-show-current-subtree)
		 (if (> allout-recent-end-of-subtree max-pos)
		     (setq max-pos allout-recent-end-of-subtree)))
		((eq curr-elem '+) (allout-show-current-branches)
		 (if (> allout-recent-end-of-subtree max-pos)
		     (setq max-pos allout-recent-end-of-subtree)))
		((eq curr-elem '-) (allout-show-current-entry))
		((eq curr-elem ':)
		 (setq stay t)
		 ;; Expand the `repeat' spec to an explicit version,
		 ;; w.r.t. remaining siblings:
		 (let ((residue	   ; = # of sibs not covered by remaining spec
			;; Dang - could be nice to make use of the chart, sigh:
			(- (length (allout-chart-siblings))
			   (length spec))))
		   (if (< 0 residue)
		       ;; Some residue - cover it with prev-elem:
		       (setq spec (append (make-list residue prev-elem)
					  spec)))))))
	 ((numberp curr-elem)
	  (if (and (>= 0 curr-elem) (allout-visible-p))
	      (save-excursion (allout-hide-current-subtree t)
			      (if (> 0 curr-elem)
				  nil
				(if (> allout-recent-end-of-subtree max-pos)
				    (setq max-pos
					  allout-recent-end-of-subtree)))))
	  (if (> (abs curr-elem) 0)
	      (progn (allout-show-children (abs curr-elem))
		     (if (> allout-recent-end-of-subtree max-pos)
			 (setq max-pos allout-recent-end-of-subtree)))))
	  ((listp curr-elem)
	   (if (allout-descend-to-depth (1+ depth))
	       (let ((got (allout-expose-topic curr-elem)))
		 (if (and got (> got max-pos)) (setq max-pos got))))))
	(cond (stay (setq stay nil))
	      ((listp (car spec)) nil)
	      ((> max-pos (point))
	       ;; Capitalize on max-pos state to get us nearer next sibling:
	       (progn (goto-char (min (point-max) max-pos))
		      (allout-next-heading)))
	      ((allout-next-sibling depth))))
      max-pos)))
;;;_   > allout-old-expose-topic (spec &rest followers)
(defun allout-old-expose-topic (spec &rest followers)

  "Deprecated.  Use allout-expose-topic \(with different schema
format\) instead.

Dictate wholesale exposure scheme for current topic, according to SPEC.

SPEC is either a number or a list.  Optional successive args
dictate exposure for subsequent siblings of current topic.

A simple spec (either a number, a special symbol, or the null list)
dictates the overall exposure for a topic.  Non null lists are
composite specs whose first element dictates the overall exposure for
a topic, with the subsequent elements in the list interpreted as specs
that dictate the exposure for the successive offspring of the topic.

Simple (numeric and null-list) specs are interpreted as follows:

 - Numbers indicate the relative depth to open the corresponding topic:
  - negative numbers force the topic to be close before opening to the
    absolute value of the number.
  - positive numbers just open to the relative depth indicated by the number.
  - 0 just closes
 - `*' completely opens the topic, including bodies.
 - `+' shows all the sub headers, but not the bodies
 - `-' exposes the body and immediate offspring of the corresponding topic.

If the spec is a list, the first element must be a number, which
dictates the exposure depth of the topic as a whole.  Subsequent
elements of the list are nested SPECs, dictating the specific exposure
for the corresponding offspring of the topic.

Optional FOLLOWER arguments dictate exposure for succeeding siblings."

  (interactive "xExposure spec: ")
  (let ((depth (allout-current-depth))
	done
	max-pos)
    (cond ((null spec) nil)
	  ((symbolp spec)
	   (if (eq spec '*) (allout-show-current-subtree))
	   (if (eq spec '+) (allout-show-current-branches))
	   (if (eq spec '-) (allout-show-current-entry)))
	  ((numberp spec)
	   (if (>= 0 spec)
	       (save-excursion (allout-hide-current-subtree t)
			       (end-of-line)
			       (if (or (not max-pos)
				       (> (point) max-pos))
				   (setq max-pos (point)))
			       (if (> 0 spec)
				   (setq spec (* -1 spec)))))
	   (if (> spec 0)
	     (allout-show-children spec)))
	  ((listp spec)
	   ;(let ((got (allout-old-expose-topic (car spec))))
	   ;  (if (and got (or (not max-pos) (> got max-pos)))
	   ;	 (setq max-pos got)))
	   (let ((new-depth  (+ (allout-current-depth) 1))
		 got)
	     (setq max-pos (allout-old-expose-topic (car spec)))
	     (setq spec (cdr spec))
	     (if (and spec
		      (allout-descend-to-depth new-depth)
		      (not (allout-hidden-p)))
		 (progn (setq got (apply 'allout-old-expose-topic spec))
			(if (and got (or (not max-pos) (> got max-pos)))
			    (setq max-pos got)))))))
    (while (and followers
		(progn (if (and max-pos (< (point) max-pos))
			   (progn (goto-char max-pos)
				  (setq max-pos nil)))
		       (end-of-line)
		       (allout-next-sibling depth)))
      (allout-old-expose-topic (car followers))
      (setq followers (cdr followers)))
    max-pos))
;;;_   > allout-new-exposure '()
(defmacro allout-new-exposure (&rest spec)
  "Literal frontend for `allout-expose-topic', doesn't evaluate arguments.
Some arguments that would need to be quoted in allout-expose-topic
need not be quoted in allout-new-exposure.

Cursor is left at start position.

Use this instead of obsolete `allout-exposure'.

Examples:
\(allout-exposure (-1 () () () 1) 0)
	Close current topic at current level so only the immediate
	subtopics are shown, except also show the children of the
	third subtopic; and close the next topic at the current level.
\(allout-exposure : -1 0)
	Close all topics at current level to expose only their
	immediate children, except for the last topic at the current
	level, in which even its immediate children are hidden.
\(allout-exposure -2 : -1 *)
        Expose children and grandchildren of first topic at current
	level, and expose children of subsequent topics at current
	level *except* for the last, which should be opened completely."
  (list 'save-excursion
	'(if (not (or (allout-goto-prefix)
		      (allout-next-heading)))
	     (error "allout-new-exposure: Can't find any allout topics."))
	(list 'allout-expose-topic (list 'quote spec))))
;;;_   > allout-exposure '()
(defmacro allout-exposure (&rest spec)
  "Being deprecated - use more recent `allout-new-exposure' instead.

Literal frontend for `allout-old-expose-topic', doesn't evaluate arguments
and retains start position."
  (list 'save-excursion
	'(if (not (or (allout-goto-prefix)
		      (allout-next-heading)))
	     (error "Can't find any allout topics."))
	(cons 'allout-old-expose-topic
	      (mapcar '(lambda (x) (list 'quote x)) spec))))

;;;_ #7 ISearch with Dynamic Exposure
;;;_  = allout-search-reconceal
(defvar allout-search-reconceal nil
  "Track whether current search match was concealed outside of search.

The value is the location of the match, if it was concealed, regular
if the entire topic was concealed, in a list if the entry was concealed.")
;;;_  = allout-search-quitting
(defconst allout-search-quitting nil
  "Distinguishes isearch conclusion and cancellation.

Used by isearch-terminate/allout-provisions and
isearch-done/allout-provisions")


;;;_  > allout-enwrap-isearch ()
(defun allout-enwrap-isearch ()
  "Impose allout-mode isearch-mode wrappers for dynamic exposure in isearch.

Isearch progressively exposes and reconceals hidden topics when
working in allout mode, but works normally elsewhere.

The function checks to ensure that the rebindings are done only once."

                                        ; Should isearch-mode be employed,
  (if (or (not allout-enwrap-isearch-mode)
                                        ; or are preparations already done?
          (fboundp 'real-isearch-terminate))

      ;; ... no - skip this all:
      nil

    ;; ... yes:

                                        ; Ensure load of isearch-mode:
    (if (or (and (fboundp 'isearch-mode)
                 (fboundp 'isearch-quote-char))
            (condition-case error
                (load-library allout-enwrap-isearch-mode)
              (file-error (message "Skipping isearch-mode provisions - %s '%s'"
                                   (car (cdr error))
                                   (car (cdr (cdr error))))
                          (sit-for 1)
                          ;; Inhibit subsequent tries and return nil:
                          (setq allout-enwrap-isearch-mode nil))))
        ;; Isearch-mode loaded, encapsulate specific entry points for
        ;; allout dynamic-exposure business:
        (progn

	  ;; stash crucial isearch-mode funcs under known, private
	  ;; names, then register wrapper functions under the old
	  ;; names, in their stead: `isearch-quit' is pre isearch v 1.2.
          (fset 'real-isearch-terminate
                                        ; `isearch-quit' is pre v 1.2:
                (or (if (fboundp 'isearch-quit)
                        (symbol-function 'isearch-quit))
                    (if (fboundp 'isearch-abort)
                                        ; `isearch-abort' is v 1.2 and on:
                        (symbol-function 'isearch-abort))))
          (fset 'isearch-quit 'isearch-terminate/allout-provisions)
          (fset 'isearch-abort 'isearch-terminate/allout-provisions)
          (fset 'real-isearch-done (symbol-function 'isearch-done))
          (fset 'isearch-done 'isearch-done/allout-provisions)
          (fset 'real-isearch-update (symbol-function 'isearch-update))
          (fset 'isearch-update 'isearch-update/allout-provisions)
          (make-variable-buffer-local 'allout-search-reconceal)))))
;;;_  > allout-isearch-arrival-business ()
(defun allout-isearch-arrival-business ()
  "Do allout business like exposing current point, if necessary.

Registers reconcealment requirements in allout-search-reconceal
accordingly.

Set allout-search-reconceal to nil if current point is not
concealed, to value of point if entire topic is concealed, and a
list containing point if only the topic body is concealed.

This will be used to determine whether allout-hide-current-entry
or allout-hide-current-entry-completely will be necessary to
restore the prior concealment state."

  (if (allout-mode-p)
      (setq allout-search-reconceal
            (if (allout-hidden-p)
                (save-excursion
                  (if (re-search-backward allout-line-boundary-regexp nil 1)
                      ;; Nil value means we got to b-o-b - wouldn't need
                      ;; to advance.
                      (forward-char 1))
                                        ; We'll return point or list
                                        ; containing point, depending
                                        ; on concealment state of
                                        ; topic prefix.
                  (prog1 (if (allout-hidden-p) (point) (list (point)))
                                        ; And reveal the current
                                        ; search target:
                    (allout-show-entry)))))))
;;;_  > allout-isearch-advancing-business ()
(defun allout-isearch-advancing-business ()
  "Do allout business like deexposing current point, if necessary.

Works according to reconceal state registration."
  (if (and (allout-mode-p) allout-search-reconceal)
      (save-excursion
        (if (listp allout-search-reconceal)
            ;; Leave the topic visible:
            (progn (goto-char (car allout-search-reconceal))
                   (allout-hide-current-entry))
          ;; Rehide the entire topic:
          (goto-char allout-search-reconceal)
          (allout-hide-current-entry-completely)))))
;;;_  > isearch-terminate/allout-provisions ()
(defun isearch-terminate/allout-provisions ()
  (interactive)
    (if (and (allout-mode-p) allout-enwrap-isearch-mode)
        (allout-isearch-advancing-business))
    (let ((allout-search-quitting t)
          (allout-search-reconceal nil))
      (real-isearch-terminate)))
;;;_  > isearch-done/allout-provisions ()
(defun isearch-done/allout-provisions (&optional nopush edit)
  (interactive)
  (if (and (allout-mode-p) allout-enwrap-isearch-mode)
      (progn (if (and allout-search-reconceal
		      (not (listp allout-search-reconceal)))
		 ;; The topic was concealed - reveal it, its siblings,
		 ;; and any ancestors that are still concealed:
		 (save-excursion
		   (message "(exposing destination)")(sit-for 0)
		   (allout-goto-prefix)
					; There may be a closed blank
					; line between prior and
					; current topic that would be
					; missed - provide for it:
		   (if (not (bobp))
		       (progn (forward-char -1) ; newline
			      (if (eq ?\r (preceding-char))
				  (allout-flag-region (1- (point))
						       (point)
						       ?\n))
			      (forward-char 1)))
					; Goto parent
		   (allout-ascend-to-depth (1- (allout-recent-depth)))
		   (allout-show-children)))
	     (if (and (boundp 'allout-search-quitting)
		      allout-search-quitting)
		 nil
					; We're concluding abort:
	       (allout-isearch-arrival-business)
	       (allout-show-children))))
  (if nopush
      ;; isearch-done in newer version of isearch mode takes arg:
      (real-isearch-done nopush edit)
    (real-isearch-done)))
;;;_  > isearch-update/allout-provisions ()
(defun isearch-update/allout-provisions ()
  "Wrapper dynamically adjusts isearch target exposure.

Appropriately exposes and reconceals hidden allout portions, as
necessary, in the course of searching."
  (if (not (and (allout-mode-p) allout-enwrap-isearch-mode))
      ;; Just do the plain business:
      (real-isearch-update)

    ;; Ah - provide for allout conditions:
    (allout-isearch-advancing-business)
    (real-isearch-update)
    (cond (isearch-success (allout-isearch-arrival-business))
          ((not isearch-success) (allout-isearch-advancing-business)))))

;;;_ #8 Copying and printing

;;;_  - Copy exposed
;;;_   > allout-insert-listified (depth prefix bullet text)
(defun allout-insert-listified (depth prefix bullet text)
  "Insert contents of listified allout portion in current buffer."
  (insert-string (concat (if (> depth 1) prefix "")
			 (make-string (1- depth) ?\ )
			 bullet))
  (while text
    (insert-string (car text))
    (if (setq text (cdr text))
	(insert-string "\n")))
  (insert-string "\n"))
;;;_   > allout-copy-exposed (arg &optional tobuf)
(defun allout-copy-exposed (arg &optional tobuf)
  "Duplicate exposed portions of current topic to another buffer.

Other buffer has current buffers' name with \" exposed\" appended to it.

With repeat count, copy the exposed portions of entire buffer."

  (interactive "P")
  (if (not tobuf)
      (setq tobuf (get-buffer-create (concat "*" (buffer-name) " exposed*"))))
  (let* ((start-pt (point))
	 (beg (if arg (point-min) (allout-back-to-current-heading)))
	 (end (if arg (point-max) (allout-end-of-current-subtree)))
	 (buf (current-buffer)))
    (save-excursion (set-buffer tobuf)(erase-buffer))
    (allout-process-exposed 'allout-insert-listified
			     beg
			     end
			     (current-buffer)
			     tobuf)
    (goto-char (point-min))
    (pop-to-buffer buf)
    (goto-char start-pt)))

;;;_  - LaTeX formatting
;;;_   > allout-latex-verb-quote (str &optional flow)
(defun allout-latex-verb-quote (str &optional flow)
  "Return copy of STRING for literal reproduction across latex processing.
Expresses the original characters \(including carriage returns) of the
string across latex processing."
  (mapconcat '(lambda (char)
       ;;;mess: (cond ((memq char '(?"" ?$ ?% ?# ?& ?- ?" ?` ?^ ?- ?*));;;"))))
		(cond ((memq char '(?\\ ?$ ?% ?# ?& ?{ ?} ?_ ?^ ?- ?*))
		       (concat "\\char" (number-to-string char) "{}"))
		      ((= char ?\n) "\\\\")
		      (t (char-to-string char))))
	     str
	     ""))
;;;_   > allout-latex-verbatim-quote-curr-line ()
(defun allout-latex-verbatim-quote-curr-line ()
  "Express line for exact \(literal\) representation across latex processing.

Adjust line contents so it is unaltered \(from the original line)
across latex processing, within the context of a `verbatim'
environment.  Leaves point at the end of the line."
  (beginning-of-line)
  (let ((beg (point))
	(end (progn (end-of-line)(point))))
    (goto-char beg)
    (while (re-search-forward "\\\\"
	    ;;"\\\\\\|\\{\\|\\}\\|\\_\\|\\$\\|\\\"\\|\\&\\|\\^\\|\\-\\|\\*\\|#"
			      end	; bounded by end-of-line
			      1)	; no matches, move to end & return nil
      (goto-char (match-beginning 0))
      (insert-string "\\")
      (setq end (1+ end))
      (goto-char (1+ (match-end 0))))))
;;;_   > allout-insert-latex-header (buf)
(defun allout-insert-latex-header (buf)
  "Insert initial latex commands at point in BUFFER."
  ;; Much of this is being derived from the stuff in appendix of E in
  ;; the TeXBook, pg 421.
  (set-buffer buf)
  (let ((doc-style (format "\n\\documentstyle{%s}\n"
			   "report"))
	(page-numbering (if allout-number-pages
			    "\\pagestyle{empty}\n"
			  ""))
	(linesdef (concat "\\def\\beginlines{"
			  "\\par\\begingroup\\nobreak\\medskip"
			  "\\parindent=0pt\n"
			  " \\kern1pt\\nobreak \\obeylines \\obeyspaces "
			  "\\everypar{\\strut}}\n"
			  "\\def\\endlines{"
			  "\\kern1pt\\endgroup\\medbreak\\noindent}\n"))
	(titlecmd (format "\\newcommand{\\titlecmd}[1]{{%s #1}}\n"
			  allout-title-style))
	(labelcmd (format "\\newcommand{\\labelcmd}[1]{{%s #1}}\n"
			  allout-label-style))
	(headlinecmd (format "\\newcommand{\\headlinecmd}[1]{{%s #1}}\n"
			     allout-head-line-style))
	(bodylinecmd (format "\\newcommand{\\bodylinecmd}[1]{{%s #1}}\n"
			     allout-body-line-style))
	(setlength (format "%s%s%s%s"
			   "\\newlength{\\stepsize}\n"
			   "\\setlength{\\stepsize}{"
			   allout-indent
			   "}\n"))
	(oneheadline (format "%s%s%s%s%s%s%s"
			     "\\newcommand{\\OneHeadLine}[3]{%\n"
			     "\\noindent%\n"
			     "\\hspace*{#2\\stepsize}%\n"
			     "\\labelcmd{#1}\\hspace*{.2cm}"
			     "\\headlinecmd{#3}\\\\["
			     allout-line-skip
			     "]\n}\n"))
	(onebodyline (format "%s%s%s%s%s%s"
			       "\\newcommand{\\OneBodyLine}[2]{%\n"
			       "\\noindent%\n"
			       "\\hspace*{#1\\stepsize}%\n"
			       "\\bodylinecmd{#2}\\\\["
			       allout-line-skip
			       "]\n}\n"))
	(begindoc "\\begin{document}\n\\begin{center}\n")
	(title (format "%s%s%s%s"
		       "\\titlecmd{"
		       (allout-latex-verb-quote (if allout-title
						(condition-case err
						    (eval allout-title)
						  (error "<unnamed buffer>"))
					      "Unnamed Allout"))
		       "}\n"
		       "\\end{center}\n\n"))
	(hsize "\\hsize = 7.5 true in\n")
	(hoffset "\\hoffset = -1.5 true in\n")
	(vspace "\\vspace{.1cm}\n\n"))
    (insert (concat doc-style
		    page-numbering
		    titlecmd
		    labelcmd
		    headlinecmd
		    bodylinecmd
		    setlength
		    oneheadline
		    onebodyline
		    begindoc
		    title
		    hsize
		    hoffset
		    vspace)
	    )))
;;;_   > allout-insert-latex-trailer (buf)
(defun allout-insert-latex-trailer (buf)
  "Insert concluding latex commands at point in BUFFER."
  (set-buffer buf)
  (insert "\n\\end{document}\n"))
;;;_   > allout-latexify-one-item (depth prefix bullet text)
(defun allout-latexify-one-item (depth prefix bullet text)
  "Insert LaTeX commands for formatting one allout item.

Args are the topics' numeric DEPTH, the header PREFIX lead string, the
BULLET string, and a list of TEXT strings for the body."
  (let* ((head-line (if text (car text)))
	 (body-lines (cdr text))
	 (curr-line)
	 body-content bop)
					; Do the head line:
    (insert-string (concat "\\OneHeadLine{\\verb\1 "
			   (allout-latex-verb-quote bullet)
			   "\1}{"
			   depth
			   "}{\\verb\1 "
			   (if head-line
			       (allout-latex-verb-quote head-line)
			     "")
			   "\1}\n"))
    (if (not body-lines)
	nil
      ;;(insert-string "\\beginlines\n")
      (insert-string "\\begin{verbatim}\n")
      (while body-lines
	(setq curr-line (car body-lines))
	(if (and (not body-content)
		 (not (string-match "^\\s-*$" curr-line)))
	    (setq body-content t))
					; Mangle any occurrences of
					; "\end{verbatim}" in text,
					; it's special:
	(if (and body-content
		 (setq bop (string-match "\\end{verbatim}" curr-line)))
	    (setq curr-line (concat (substring curr-line 0 bop)
				    ">"
				    (substring curr-line bop))))
	;;(insert-string "|" (car body-lines) "|")
	(insert-string curr-line)
	(allout-latex-verbatim-quote-curr-line)
	(insert-string "\n")
	(setq body-lines (cdr body-lines)))
      (if body-content
	  (setq body-content nil)
	(forward-char -1)
	(insert-string "\\ ")
	(forward-char 1))
      ;;(insert-string "\\endlines\n")
      (insert-string "\\end{verbatim}\n")
      )))
;;;_   > allout-latexify-exposed (arg &optional tobuf)
(defun allout-latexify-exposed (arg &optional tobuf)
  "Format current topic's exposed portions to TOBUF for latex processing.
TOBUF defaults to a buffer named the same as the current buffer, but
with \"*\" prepended and \" latex-formed*\" appended.

With repeat count, copy the exposed portions of entire buffer."

  (interactive "P")
  (if (not tobuf)
      (setq tobuf
	    (get-buffer-create (concat "*" (buffer-name) " latexified*"))))
  (let* ((start-pt (point))
	 (beg (if arg (point-min) (allout-back-to-current-heading)))
	 (end (if arg (point-max) (allout-end-of-current-subtree)))
	 (buf (current-buffer)))
    (set-buffer tobuf)
    (erase-buffer)
    (allout-insert-latex-header tobuf)
    (goto-char (point-max))
    (allout-process-exposed 'allout-latexify-one-item
			     beg
			     end
			     buf
			     tobuf)
    (goto-char (point-max))
    (allout-insert-latex-trailer tobuf)
    (goto-char (point-min))
    (pop-to-buffer buf)
    (goto-char start-pt)))

;;;_ #9 miscellaneous
;;;_  > allout-mark-topic ()
(defun allout-mark-topic ()
  "Put the region around topic currently containing point."
  (interactive)
  (beginning-of-line)
  (allout-goto-prefix)
  (push-mark (point))
  (allout-end-of-current-subtree)
  (exchange-point-and-mark))
;;;_  > outlineify-sticky ()
;; outlinify-sticky is correct spelling; provide this alias for sticklers:
(defalias 'outlinify-sticky 'outlineify-sticky)
(defun outlineify-sticky (&optional arg)
  "Activate allout mode and establish file var so it is started subsequently.

See doc-string for `allout-layout' and `allout-init' for details on
setup for auto-startup."

  (interactive "P")

  (allout-mode t)

  (save-excursion
    (goto-char (point-min))
    (if (looking-at allout-regexp)
	t
      (allout-open-topic 2)
      (insert-string (concat "Dummy allout topic header - see"
			     "`allout-mode' docstring for info."))
      (next-line 1)
      (goto-char (point-max))
      (next-line 1)
      (allout-open-topic 0)
      (insert-string "Local emacs vars.\n")
      (allout-open-topic 1)
      (insert-string "(`allout-layout' is for allout.el allout-mode)\n")
      (allout-open-topic 0)
      (insert-string "Local variables:\n")
      (allout-open-topic 0)
      (insert-string (format "allout-layout: %s\n"
			     (or allout-layout
				 '(1 : 0))))
      (allout-open-topic 0)
      (insert-string "End:\n"))))
;;;_  > solicit-char-in-string (prompt string &optional do-defaulting)
(defun solicit-char-in-string (prompt string &optional do-defaulting)
  "Solicit (with first arg PROMPT) choice of a character from string STRING.

Optional arg DO-DEFAULTING indicates to accept empty input (CR)."

  (let ((new-prompt prompt)
        got)

    (while (not got)
      (message "%s" new-prompt)

      ;; We do our own reading here, so we can circumvent, eg, special
      ;; treatment for `?' character.  (Might oughta change minibuffer
      ;; keymap instead, oh well.)
      (setq got
            (char-to-string (let ((cursor-in-echo-area nil)) (read-char))))

      (if (null (string-match (regexp-quote got) string))
          (if (and do-defaulting (string= got "\^M"))
              ;; We're defaulting, return null string to indicate that:
              (setq got "")
            ;; Failed match and not defaulting,
            ;; set the prompt to give feedback,
            (setq new-prompt (concat prompt
                                     got
                                     " ...pick from: "
                                     string
                                     ""))
            ;; and set loop to try again:
            (setq got nil))
        ;; Got a match - give feedback:
        (message "")))
    ;; got something out of loop - return it:
    got)
  )
;;;_  > regexp-sans-escapes (string)
(defun regexp-sans-escapes (regexp &optional successive-backslashes)
  "Return a copy of REGEXP with all character escapes stripped out.

Representations of actual backslashes - '\\\\\\\\' - are left as a
single backslash.

Optional arg SUCCESSIVE-BACKSLASHES is used internally for recursion."

  (if (string= regexp "")
      ""
    ;; Set successive-backslashes to number if current char is
    ;; backslash, or else to nil:
    (setq successive-backslashes
	  (if (= (aref regexp 0) ?\\)
	      (if successive-backslashes (1+ successive-backslashes) 1)
	    nil))
    (if (or (not successive-backslashes) (= 2 successive-backslashes))
	;; Include first char:
	(concat (substring regexp 0 1)
		(regexp-sans-escapes (substring regexp 1)))
      ;; Exclude first char, but maintain count:
      (regexp-sans-escapes (substring regexp 1) successive-backslashes))))
;;;_  - add-hook definition for divergent emacsen
;;;_   > add-hook (hook function &optional append)
(if (not (fboundp 'add-hook))
    (defun add-hook (hook function &optional append)
      "Add to the value of HOOK the function FUNCTION unless already present.
\(It becomes the first hook on the list unless optional APPEND is non-nil, in
which case it becomes the last).  HOOK should be a symbol, and FUNCTION may be
any valid function.  HOOK's value should be a list of functions, not a single
function.  If HOOK is void, it is first set to nil."
      (or (boundp hook) (set hook nil))
      (or (if (consp function)
	      ;; Clever way to tell whether a given lambda-expression
	      ;; is equal to anything in the hook.
	      (let ((tail (assoc (cdr function) (symbol-value hook))))
		(equal function tail))
	    (memq function (symbol-value hook)))
	  (set hook
	       (if append
		   (nconc (symbol-value hook) (list function))
		 (cons function (symbol-value hook)))))))

;;;_ #10 Under development
;;;_  > allout-bullet-isearch (&optional bullet)
(defun allout-bullet-isearch (&optional bullet)
  "Isearch \(regexp\) for topic with bullet BULLET."
  (interactive)
  (if (not bullet)
      (setq bullet (solicit-char-in-string
		    "ISearch for topic with bullet: "
		    (regexp-sans-escapes allout-bullets-string))))

  (let ((isearch-regexp t)
	(isearch-string (concat "^"
				allout-header-prefix
				"[ \t]*"
				bullet)))
    (isearch-repeat 'forward)
    (isearch-mode t)))
;;;_  ? Re hooking up with isearch - use isearch-op-fun rather than
;;;	wrapping the isearch functions.

;;;_* Local emacs vars.
;;; The following `allout-layout' local variable setting:
;;;  - closes all topics from the first topic to just before the third-to-last,
;;;  - shows the children of the third to last (config vars)
;;;  - and the second to last (code section),
;;;  - and closes the last topic (this local-variables section).
;;;Local variables:
;;;allout-layout: (0 : -1 -1 0)
;;;End:

;; allout.el ends here
