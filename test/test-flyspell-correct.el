;;; test-flyspell-correct.el --- flyspell-correct tests -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2020 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 04 Feb 2020
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

(require 'buttercup)
(require 'flyspell-correct)

(defun cursor-position (cursor)
  "Return position of CURSOR string in current buffer.

CURSOR is removed from the buffer."
  (goto-char (point-min))
  (ignore-errors
    (search-forward cursor)
    (delete-char (- (length cursor)))
    (point)))

(defun cursors-position (initial-cursor end-cursor)
  "Return positions of INITIAL-CURSOR and END-CURSOR.

Cursors are removed from the buffer."
  (let* ((initial-point0 (cursor-position initial-cursor))
         (end-point0 (or (cursor-position end-cursor)
                         initial-point0))
         (initial-point initial-point0)
         (end-point end-point0))
    (when (> initial-point0 end-point0)
      (setq initial-point (- initial-point (length end-cursor))))
    (list initial-point end-point)))

(defmacro with-no-mistakes (&rest body)
  "Execute BODY in temporary buffer that has no mistakes."
  `(with-flyspell-buffer
    "The| licenses for most software and other practical works
are designed to take away your freedom to share and change the
works. By contrast, the GNU General Public License is intended to
guarantee your freedom to share and change all versions of a
program--to make sure it remains free software for all its users.
We, the Free Software Foundation, use the GNU General Public
License for most of our software; it applies also to any other
work released this way by its authors. You can apply it to your
programs, too." ,@body))

(defmacro with-mistakes|cursor-beginning (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed at the beginning of the misspelled word."
  `(with-flyspell-buffer
    "The licenses for most software and other practical works are
designed to take away your freedom to share and change the works.
By contrast, the GNU Generel Public License is intended to
guarantee your freedom to share and change all |†versiuns of a
program--to make sure it remains free software for all its users.
We, the Free Software Foundation, use the GNU General Public
License for most of our software; it applies also to any other
werk released this way by its authors. You can apply it to your
programs, too." ,@body))

(defmacro with-mistakes|cursor-before-all (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed somewhere before the misspelled word."
  `(with-flyspell-buffer
    "The licenses |for most software and other practical works
are designed to take away your freedom to share and change the
works. By contrast, the GNU Generel Public License is intended to
guarantee your freedom to share and change all versiuns of a
program--to make sure it remains free software for all its users.
We, the Free Software Foundation, use the GNU General Public
License for most of our software; it applies also to any other
werk released this way by its authors. You can apply it to your
programs, too." ,@body))

(defmacro with-mistakes|cursor-before (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed somewhere before the misspelled word."
  `(with-flyspell-buffer
    "The licenses for most software and other practical works are
designed to take away your freedom to share and change the works.
By contrast, the GNU Generel Public License |is intended to
guarantee your freedom to share and change all versiuns of a
program--to make sure it remains free software for all its users.
We, the Free Software Foundation, use the GNU General Public
License for most of our software; it applies also to any other
werk released this way by its authors. You can apply it to your
programs, too." ,@body))

(defmacro with-mistakes|cursor-inside (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed inside of the misspelled word."
  `(with-flyspell-buffer
    "The licenses for most software and other practical works are
designed to take away your freedom to share and change the works.
By contrast, the GNU Generel Public License is intended to
guarantee your freedom to share and change all ver†|siuns of a
program--to make sure it remains free software for all its users.
We, the Free Software Foundation, use the GNU General Public
License for most of our software; it applies also to any other
werk released this way by its authors. You can apply it to your
programs, too." ,@body))

(defmacro with-mistakes|cursor-end (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed at the end of the misspelled word."
  `(with-flyspell-buffer
    "The licenses for most software and other practical works are
designed to take away your freedom to share and change the works.
By contrast, the GNU Generel Public License is intended to
guarantee your freedom to share and change all versiuns†| of a
program--to make sure it remains free software for all its users.
We, the Free Software Foundation, use the GNU General Public
License for most of our software; it applies also to any other
werk released this way by its authors. You can apply it to your
programs, too." ,@body))

(defmacro with-mistakes|cursor-after (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed somewhere after the misspelled word."
  `(with-flyspell-buffer
    "The licenses for most software and other practical works are
designed to take away your freedom to share and change the works.
By contrast, the GNU Generel Public License is intended to
guarantee your freedom to share and change all versiuns of a
program--to make sure it remains free software for all| its
users. We, the Free Software Foundation, use the GNU General
Public License for most of our software; it applies also to any
other werk released this way by its authors. You can apply it to
your programs, too." ,@body))

(defmacro with-mistakes|cursor-after-all (&rest body)
  "Execute BODY in temporary buffer that has a mistake.

Cursor is placed somewhere after the misspelled word."
  `(with-flyspell-buffer
    "The licenses for most software and other practical works are
designed to take away your freedom to share and change the works.
By contrast, the GNU Generel Public License is intended to
guarantee your freedom to share and change all versiuns of a
program--to make sure it remains free software for all its
users. We, the Free Software Foundation, use the GNU General
Public License for most of our software; it applies also to any
other werk released this way by its |authors. You can apply it to
your programs, too." ,@body))

(defmacro with-flyspell-buffer (text &rest body)
  "Run the test in the temporary buffer containing TEXT.

1. Creates temporary buffer and inserts TEXT into it.
2. Runs flyspell on the buffer.
3. Places cursor on '|' character.
4. Runs the BODY which should call one of the `flyspell-correct'
   functions and define expectations.
5. Checks that point is located at the position '†' character in
   the buffer (or '|')."
  `(with-temp-buffer
     (insert ,text)
     (let ((ispell-dictionary-alist
            '((nil "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-B") nil iso-8859-1)
              ("english" "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-B") nil iso-8859-1)))
           (ispell-current-dictionary "english"))
       (let* ((points (cursors-position "|" "†"))
              (initial-point (car points))
              (end-point (cadr points)))
         (quiet
          (flyspell-buffer)
          (goto-char initial-point)
          ,@body)
         (expect (point) :to-be end-point)))))

(defmacro quiet (&rest forms)
  "Run FORMS without generating any output.

This silences calls to `message' and anything that writes to
`standard-output'."
  `(cl-letf ((standard-output (lambda (&rest _)))
             ((symbol-function 'message) (lambda (&rest _))))
     ,@forms))

(defun correct-word (_)
  "Mock function for testing `correct-interface'.")

(defun correct-interface (_ word)
  "Dummy interface for `flyspell-correct'.

Simply passed WORD to `correct-word' mock."
  (correct-word word))

(defun expect-correction (misspelled)
  "Expect correction interface to be called on MISSPELLED word."
  (expect 'correct-interface :to-have-been-called-times 1)
  (expect 'correct-word :to-have-been-called-times 1)
  (expect 'correct-word :to-have-been-called-with misspelled))

(describe "flyspell-correct-at-point"

  (before-each
    (setq flyspell-correct-interface #'correct-interface))

  (it "don't call correct when word is correct"
    (with-no-mistakes
     (spy-on 'correct-interface)
     (expect (flyspell-correct-at-point) :to-equal nil)
     (expect 'correct-interface :not :to-have-been-called)))

  (describe "action - skip"

    (before-each
      (spy-on 'correct-interface :and-call-through)
      (spy-on 'correct-word :and-call-fake (lambda (word) (cons 'skip word))))

    (it "call correct when the cursor is at the beginning of misspelled word"
      (with-mistakes|cursor-beginning
       (expect (flyspell-correct-at-point) :to-equal (cons 'skip "versiuns"))
       (expect-correction "versiuns")))

    (it "call correct when the cursor is inside of misspelled word"
      (with-mistakes|cursor-inside
       (expect (flyspell-correct-at-point) :to-equal (cons 'skip "versiuns"))
       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the end of misspelled word"
      (with-mistakes|cursor-end
       (expect (flyspell-correct-at-point) :to-equal (cons 'skip "versiuns"))
       (expect-correction "versiuns"))))

  (describe "action - fix"
    (before-each
      (spy-on 'correct-interface :and-call-through)
      (spy-on 'correct-word :and-return-value "versions"))

    (it "call correct when the cursor is at the beginning of misspelled word"
      (with-mistakes|cursor-beginning
       (expect (flyspell-correct-at-point) :to-equal "versions")
       (expect-correction "versiuns")))

    (it "call correct when the cursor is inside of misspelled word"
      (with-mistakes|cursor-inside
       (expect (flyspell-correct-at-point) :to-equal "versions")
       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the end of misspelled word"
      (with-mistakes|cursor-end
       (expect (flyspell-correct-at-point) :to-equal "versions")
       (expect-correction "versiuns")))))

(describe "flyspell-correct-next"

  (before-each
    (setq flyspell-correct-interface #'correct-interface))

  (it "don't call correct when word is correct"
    (with-no-mistakes
     (spy-on 'correct-interface)
     (expect (flyspell-correct-next (point)) :to-be nil)
     (expect 'correct-interface :not :to-have-been-called)))

  (it "don't call correct when there are no misspelled words after point"
    (with-mistakes|cursor-after-all
     (spy-on 'correct-interface)
     (expect (flyspell-correct-next (point)) :to-be nil)
     (expect 'correct-interface :not :to-have-been-called)))

  (describe "action - skip"

    (before-each
      (spy-on 'correct-interface :and-call-through)
      (spy-on 'correct-word :and-call-fake (lambda (word) (cons 'skip word))))

    (it "call correct when the cursor is before misspelled word"
      (with-mistakes|cursor-before
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the beginning of misspelled word"
      (with-mistakes|cursor-beginning
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is inside of misspelled word"
      (with-mistakes|cursor-inside
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the end of misspelled word"
      (with-mistakes|cursor-end
       (flyspell-correct-next (point))

       (expect-correction "versiuns"))))

  (describe "action - fix"

    (before-each
      (spy-on 'correct-interface :and-call-through)
      (spy-on 'correct-word :and-return-value "versions"))

    (it "call correct when the cursor is before misspelled word"
      (with-mistakes|cursor-before
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the beginning of misspelled word"
      (with-mistakes|cursor-beginning
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is inside of misspelled word"
      (with-mistakes|cursor-inside
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the end of misspelled word"
      (with-mistakes|cursor-end
       (flyspell-correct-next (point))

       (expect-correction "versiuns")))))

(describe "flyspell-correct-previous"

  (before-each
    (setq flyspell-correct-interface #'correct-interface))

  (it "don't call correct when word is correct"
    (with-no-mistakes
     (spy-on 'correct-interface)
     (flyspell-correct-previous (point))
     (expect 'correct-interface :not :to-have-been-called)))

  (it "don't call correct when there are no misspelled words before point"
    (with-mistakes|cursor-before-all
     (spy-on 'correct-interface)
     (flyspell-correct-previous (point))
     (expect 'correct-interface :not :to-have-been-called)))

  (describe "action - skip"

    (before-each
      (spy-on 'correct-interface :and-call-through)
      (spy-on 'correct-word :and-call-fake (lambda (word) (cons 'skip word))))

    (it "call correct when the cursor is at the beginning of misspelled word"
      (with-mistakes|cursor-beginning
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is inside of misspelled word, but skip"
      (with-mistakes|cursor-inside
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the end of misspelled word"
      (with-mistakes|cursor-end
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is after misspelled word"
      (with-mistakes|cursor-after
       (flyspell-correct-previous (point))

       (expect-correction "versiuns"))))

  (describe "action - fix"

    (before-each
      (spy-on 'correct-interface :and-call-through)
      (spy-on 'correct-word :and-return-value "versions"))

    (it "call correct when the cursor is at the beginning of misspelled word"
      (with-mistakes|cursor-beginning
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is inside of misspelled word"
      (with-mistakes|cursor-inside
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is at the end of misspelled word"
      (with-mistakes|cursor-end
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))

    (it "call correct when the cursor is after misspelled word"
      (with-mistakes|cursor-after
       (flyspell-correct-previous (point))

       (expect-correction "versiuns")))))

(provide 'test-flyspell-correct)
;;; test-flyspell-correct.el ends here