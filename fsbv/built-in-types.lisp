;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; built-in-types.lisp -- Define libffi-type-pointers for built-in types and typedefs
;;;
;;; Copyright (C) 2011 Liam M. Healy  <lhealy@common-lisp.net>
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use, copy,
;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;; of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.
;;;

(in-package #:cffi-fsbv)

(defun set-libffi-type-pointer-for-built-in (type &optional (libffi-name type))
  (setf (slot-value (parse-type type) 'libffi-type-pointer)
        (cffi:foreign-symbol-pointer
         (format nil "ffi_type_~(~a~)" libffi-name))))

;;; Set the type pointers for non-integer built-in types
(dolist (type (append cffi:*built-in-float-types* cffi:*other-builtin-types*))
  (set-libffi-type-pointer-for-built-in type))

;;; Set the type pointers for integer built-in types
(dolist (type cffi:*built-in-integer-types*)
  (set-libffi-type-pointer-for-built-in
   type
   (format
    nil
    "~aint~d"
    (if (string-equal type "unsigned" :end1 (min 8 (length (string type))))
        "u" "s")
    (* 8 (cffi:foreign-type-size type)))))

;;; Set the type pointer on demand for alias (e.g. typedef) types
(defmethod libffi-type-pointer :around ((type cffi::foreign-type-alias))
  (or (call-next-method)
      (setf (slot-value type 'libffi-type-pointer)
            (libffi-type-pointer (cffi::follow-typedefs type)))))