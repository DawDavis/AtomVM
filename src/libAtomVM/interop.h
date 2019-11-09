/***************************************************************************
 *   Copyright 2018 by Davide Bettio <davide@uninstall.it>                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Lesser General Public License as        *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef _INTEROP_H_
#define _INTEROP_H_

#include "term.h"

char *interop_term_to_string(term t, int *ok);
char *interop_binary_to_string(term binary);
char *interop_list_to_string(term list, int *ok);
term interop_proplist_get_value(term list, term key);
term interop_proplist_get_value_default(term list, term key, term default_value);

int interop_iolist_size(term t, int *ok);
int interop_write_iolist(term t, char *p);

#endif
