;; -*- lexical-binding: t -*-

;; Copyright (C) 2024 Alan Urmancheev
;; License: MIT
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

(defun alurm-copy-last-indent-and-delete-trailing ()
  (let ((indentation
         (save-excursion
           (backward-char)
           (if (re-search-backward
                ;; Look for zero or more whitespace at the start of a non-empty line.
                ;; This is a little bit clumsy:
                ;; If the line is full of whitespace, (not "\n") will capture the last whitespace character.
                ;; It will be readded later.
                (rx line-start (group (zero-or-more (or "\t" " "))) (not "\n"))
                ;; Don't limit search (the default).
                ;; If search fails, return nil instead of erroring out.
                nil t)
               (let*
                   ((indentation (match-string 1))
                    (maybe-part-of-indentation (char-after (+ (point) (length indentation)))))
                 (concat indentation
                         (if (seq-contains-p "\t " maybe-part-of-indentation)
                             (string maybe-part-of-indentation)
                           "")))
             ;; If no previous indentation is found, the empty string is assumed.
             ""))))
    ;; This method creates lines with only whitespace, so this cleanup is needed.
    (save-excursion
      (backward-char)
      (delete-trailing-whitespace (line-beginning-position) (line-end-position)))
    (insert indentation)))


(defun alurm-copy-last-indent-and-delete-trailing-if-on-new-line ()
  "If point is on a new line, copy indent from the last non-empty line and delete trailing whitespace from the last line."
  (when (equal (char-before (point)) ?\n)
    (alurm-copy-last-indent-and-delete-trailing)))

(define-minor-mode alurm-copy-indent-mode
  "Toggle copying indent from the last non-empty line and deletion of trailing whitespace on newline.

This is a global minor mode."
  :global t :init-value nil :lighter " AlurmCopy"
  (if (not alurm-copy-indent-mode)
      (remove-hook 'post-self-insert-hook #'alurm-copy-last-indent-and-delete-trailing-if-on-new-line)
      (add-hook 'post-self-insert-hook #'alurm-copy-last-indent-and-delete-trailing-if-on-new-line)))
