# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.test import TestCase
from note.models import Post
from django.utils import timezone
from django.core.urlresolvers import reverse
from note.forms import PostForm
from django.test import Client

class NoteTest(TestCase):

    #create note for testing
    def create_note(self, title="test title", text="yes, this is only a test"):
        return Post.objects.create(title=title, text=text, created_date=timezone.now(), published_date=timezone.now())

    #test creation of note
    def test_post_creation(self):
        p = self.create_note()
        self.assertTrue(isinstance(p, Post))
        self.assertEqual(str(p), p.title)

    #test note list view
    def test_post_list_view(self):
        p = self.create_note()
        url = reverse("post_list")
        resp = self.client.get(url)
      
        self.assertContains(resp, p.title, status_code=200)

    #test note details view
    def test_post_details_view(self):
        p = self.create_note()
        url = reverse("post_detail", args=[p.id])
        resp = self.client.get(url)

        self.assertContains(resp, p.title, status_code=200)

    #test new note view
    def test_post_new_view(self):
        url = reverse("post_new")
        resp = self.client.get(url)
         
        self.assertContains(resp, "New Note", status_code=200)

    #test note edit view
    def test_post_edit_view(self):
        p = self.create_note()
        url = reverse("post_edit", args=[p.id])
        resp = self.client.get(url)

        self.assertContains(resp, p.title, status_code=200)

    #test valid form
    def test_valid_form(self):
        p = Post.objects.create(title='test title', text='test')
        data = {'title': p.title, 'text': p.text,}
        form = PostForm(data=data)
        self.assertTrue(form.is_valid())
        
    #test invalid form
    def test_invalid_form(self):
        p = Post.objects.create(title='test title', text='')
        data = {'title': p.title, 'text': p.text,}
        form = PostForm(data=data)
        self.assertFalse(form.is_valid())
    #test new post (post)
    def test_new_post_post(self):
        c = Client()
        url = reverse("post_new")
        resp = c.post(url, {'title':'test title', 'text':'test text',})
        p = Post.objects.latest('created_date')
        redir_url = reverse("post_detail", args=[p.id])
     
        self.assertRedirects(resp, redir_url , status_code=302, target_status_code=200)
        self.assertEqual(p.title, "test title")

    #test edit post (post)
    def test_edit_post_post(self):
        c = Client()
        p = Post.objects.create(title='test title', text='test')
        url = reverse("post_edit", args=[p.id])

        resp = c.post(url, {'title':'test edit title', 'text':'test edit',})
        redir_url = reverse("post_detail", args=[p.id])
        pedit = Post.objects.get(id=p.id)
        self.assertRedirects(resp, redir_url , status_code=302, target_status_code=200)
        self.assertEqual(pedit.title, "test edit title")
        self.assertEqual(pedit.text, "test edit")
