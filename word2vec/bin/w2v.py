#!/usr/bin/env python
# -*- coding: utf-8 -*-

import random
import time
import logging
import sys
import os
import yaml

import gensim
import numpy as np
import click


logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s',
                    level=logging.INFO)


@click.group()
def w2v():
    pass


@w2v.group()
def train():
    pass


@w2v.command()
@click.argument('input')
@click.argument('output_bin')
@click.argument('output_text', required=False)
def fasttext_to_gensim(input, output_bin, output_text=None):
    if not output_text:
        output_text = output_bin + '.txt'
    model = gensim.models.FastText.load_fasttext_format(input)
    model.save(output_bin)
    model.wv.save_word2vec_format(output_text, binary=False)


@w2v.command()
@click.argument('input')
@click.argument('output')
def gensim_to_text(input, output):
    model = gensim.models.Word2Vec.load(model_path)
    model.wv.save_word2vec_format(output, binary=False)


def _corpus_to_sentences(corpus_path):
    sentences = []
    with open(corpus_path, 'r') as sentences_file:
        for line in sentences_file:
            sentences.append(line.strip().split(' '))
    return sentences


@train.command()
@click.argument('corpus')
@click.argument('output')
@click.option('--retrain', is_flag=True, default=False)
@click.option('--init_w2v', default=None)
@click.option('--update_init_w2v', is_flag=True, default=False)
@click.option('--size', default=100)
@click.option('--window', default=5)
@click.option('--min_count', default=5)
@click.option('--seed', default=1)
@click.option('--workers', default=3)
@click.option('--algo', default='skipgram',
              type=click.Choice(['skipgram', 'cbow']))
@click.option('--negative', default=5)
@click.option('--cbow_mean', default=True)
@click.option('--epoch', default=5)
@click.option('--lr', default=0.025)
@click.option('--min_lr', default=0.0001)
def word2vec(corpus, output, retrain=False, init_w2v=None, size=100, window=5,
             min_count=5, seed=1, workers=3, algo='skipgram', negative=5,
             cbow_mean=True, epoch=5, lr=0.025, min_lr=0.0001,
             update_init_w2v=False):
    # parse args
    if algo == 'skipgram':
        sg = 1
    elif algo == 'cbow':
        sg = 0

    if negative > 0:
        hs = 0
    else:
        hs = 1

    if cbow_mean:
        cbow_mean = 1
    else:
        cbow_mean = 0

    if update_init_w2v:
        lockf = 1.0
    else:
        lockf = 0.0

    alpha = lr
    min_alpha = min_lr
    iter = epoch

    # load sentences
    sentences = _corpus_to_sentences(corpus)

    if retrain:
        if not os.path.exists(retrain):
            print('output not exists')
            sys.exit(1)
        print('load model', output)
        time.sleep(3)
        model = gensim.models.word2vec.Word2Vec.load(output)
        model.build_vocab(sentences, update=True)
        model.train(sentences, total_examples=model.corpus_count,
                    epochs=iter)
    else:
        if init_w2v:
            print('load word2vec', init_w2v)
            time.sleep(3)
            model = gensim.models.word2vec.Word2Vec(
                size=size, window=window, min_count=min_count, seed=seed,
                workers=workers, sg=sg, hs=hs, negative=negative,
                cbow_mean=cbow_mean, alpha=alpha, min_alpha=min_alpha,
                iter=iter)
            model.build_vocab(sentences)
            model.intersect_word2vec_format(init_w2v, lockf=lockf)
            model.train(sentences, total_examples=model.corpus_count,
                        epochs=model.iter)
        else:
            model = gensim.models.word2vec.Word2Vec(
                sentences, size=size, window=window, min_count=min_count,
                seed=seed, workers=workers, sg=sg, hs=hs, negative=negative,
                cbow_mean=cbow_mean, alpha=alpha, min_alpha=min_alpha,
                iter=iter)

    model.save(output)
    model.wv.save_word2vec_format(output + ".txt", binary=False)


@train.command()
@click.argument('corpus')
@click.argument('output')
@click.option('--retrain', is_flag=True, default=False)
@click.option('--word_ngrams', is_flag=True, default=True)
@click.option('--init_w2v', default=None)
@click.option('--size', default=100)
@click.option('--window', default=5)
@click.option('--min_count', default=5)
@click.option('--seed', default=1)
@click.option('--workers', default=3)
@click.option('--algo', default='skipgram',
              type=click.Choice(['skipgram', 'cbow']))
@click.option('--negative', default=5)
@click.option('--cbow_mean', default=True)
@click.option('--epoch', default=5)
@click.option('--lr', default=0.025)
@click.option('--min_lr', default=0.0001)
@click.option('--ns_exponent', default=0.75)
@click.option('--min_n', default=3)
@click.option('--max_n', default=6)
def fasttext(corpus, output, retrain=False, init_w2v=None, size=100, window=5,
             min_count=5, word_ngrams=True, seed=1, workers=3, algo='skipgram',
             negative=5, ns_exponent=0.75, cbow_mean=True, min_n=3, max_n=6,
             epoch=5, lr=0.025, min_lr=0.0001):
    # parse args
    if algo == 'skipgram':
        sg = 1
    elif algo == 'cbow':
        sg = 0

    if negative > 0:
        hs = 0
    else:
        hs = 1

    if cbow_mean:
        cbow_mean = 1
    else:
        cbow_mean = 0

    if word_ngrams:
        word_ngrams = 1
    else:
        word_ngrams = 0

    alpha = lr
    min_alpha = min_lr
    iter = epoch

    # load sentences
    sentences = _corpus_to_sentences(corpus)

    if retrain:
        if not os.path.exists(retrain):
            print('output not exists')
            sys.exit(1)
        print('load model', output)
        time.sleep(3)
        model = gensim.models.FastText.load(output)
        model.build_vocab(sentences, update=True)
        model.train(sentences, total_examples=model.corpus_count,
                    epochs=iter)
    else:
        if init_w2v:
            print('load word2vec', init_w2v)
            time.sleep(3)
            model = gensim.models.FastText(
                size=size, window=window, min_count=min_count, seed=seed,
                word_ngrams=word_ngrams, ns_exponent=ns_exponent, min_n=min_n,
                max_n=max_n, workers=workers, sg=sg, hs=hs, negative=negative,
                cbow_mean=cbow_mean, alpha=alpha, min_alpha=min_alpha,
                iter=iter)
            model.build_vocab(sentences)
            model.intersect_word2vec_format(init_w2v)
            model.train(sentences, total_examples=model.corpus_count,
                        epochs=model.iter)
        else:
            model = gensim.models.FastText(
                sentences,
                size=size, window=window, min_count=min_count, seed=seed,
                word_ngrams=word_ngrams, ns_exponent=ns_exponent, min_n=min_n,
                max_n=max_n, workers=workers, sg=sg, hs=hs, negative=negative,
                cbow_mean=cbow_mean, alpha=alpha, min_alpha=min_alpha,
                iter=iter)

    model.save(output)
    model.wv.save_word2vec_format(output + ".txt", binary=False)


@w2v.command()
@click.argument('input')
@click.argument('test_config_path', required=False)
@click.option('--binary/--text', default=True)
@click.option('--is_fasttext/--is_gensim', default=False)
def test(input, test_config_path=None, binary=True, is_fasttext=False):
    if not input or not os.path.exists(input):
        return

    if not test_config_path:
        test_config_path = './test.yaml'

    if not binary:
        is_fasttext = False

    if not binary:
        model = gensim.models.KeyedVectors.load_word2vec_format(input)
    elif is_fasttext:
        model = gensim.models.FastText.load_fasttext_format(input)
    else:
        model = gensim.models.Word2Vec.load(input)

    config = None
    with open(test_config_path, 'r') as config_file:
        config = yaml.load(config_file)

    with open(input + '.report', 'w') as report_file:
        # similarity
        def similarity(word1, word2):
            try:
                similarity = model.similarity(word1, word2)
            except:
                similarity = 'ERROR'
                pass
            print('"{}" 和 "{}" 的相似度: '.format(word1, word2),
                  similarity, file=report_file)

        for item in config:
            if 'similarity' in item:
                test = item['similarity']
                similarity(test[0], test[1])
        print(file=report_file)

        words = [item['most_similar'] for item in config if 'most_similar' in item]
        for word in words:
            print('和 "{}" 最相似的词'.format(word), file=report_file)
            try:
                for word, similarity in model.most_similar(word, topn=5):
                    print('{}: {}'.format(word, similarity), file=report_file)
            except:
                print('ERROR', file=report_file)
            print(file=report_file)

        def vec_most_similar(positive, negative, topn):
            print('和 {}-{} 关系相似的是 {}-'.format(
                positive[0], positive[1], negative),
                file=report_file
            )
            try:
                for word, similarity in model.most_similar(
                    positive=positive, negative=negative, topn=topn
                ):
                    print('{}: {}'.format(word, similarity), file=report_file)
            except:
                print('ERROR', file=report_file)
            print(file=report_file)

        for item in config:
            if 'vec_most_similar' in item:
                positive = item['vec_most_similar']['positive']
                negative = item['vec_most_similar']['negative']
                topn = 5
                vec_most_similar(positive, negative, topn)

        def not_match(words):
            print(' '.join(words), " 中不合群的词", file=report_file)
            try:
                print(model.doesnt_match(words), file=report_file)
            except:
                print('ERROR', file=report_file)
            print(file=report_file)

        for item in config:
            if 'not_match' in item:
                not_match(item['not_match'])


# # 训练模型
# if is_training:
#     sentences = []
#     with open(sentences_path, 'r') as sentences_file:
#         for line in sentences_file:
#             sentences.append(line.strip().split(' '))
#
#     if os.path.exists(model_path):
#         print('load model', model_path)
#         time.sleep(3)
#         model = gensim.models.word2vec.Word2Vec.load(model_path)
#         model.build_vocab(sentences)
#         model.train(sentences, total_examples=model.corpus_count, epochs=model.iter)
#     elif os.path.exists(model_text_path):
#         print('load word2vec', model_text_path)
#         time.sleep(3)
#         model = gensim.models.word2vec.Word2Vec(
#             size=size, window=5,
#             min_count=1, seed=1234567, workers=1000,
#             hs=1, negative=negative, cbow_mean=1, iter=epoch)
#         model.build_vocab(sentences)
#         model.intersect_word2vec_format(model_text_path)
#         model.train(sentences, total_examples=model.corpus_count, epochs=model.iter)
#     else:
#         model = gensim.models.word2vec.Word2Vec(
#             sentences, size=size, window=5,
#             min_count=1, seed=1234567, workers=1000,
#             hs=1, negative=negative, cbow_mean=1, iter=epoch)
#
#     # 保存模型，加载模型(包含字典树，可以增量训练)
#     model.save(model_path)
#     model.wv.save_word2vec_format(model_path + ".txt", binary=False)
# else:
#     if is_fasttext and model_path and os.path.exists(model_path):
#         model = gensim.models.FastText.load_fasttext_format(model_path)
#         if not os.path.exists(model_text_path):
#             model.wv.save_word2vec_format(model_text_path, binary=False)
#     elif model_path and os.path.exists(model_path):
#         model = gensim.models.Word2Vec.load(model_path)
#     elif model_text_path and os.path.exists(model_text_path):
#         model = gensim.models.KeyedVectors.load_word2vec_format(
#             model_text_path)
#
#     # similarity
#     def similarity(a, b):
#         try:
#             print('"{}"和"{}"的相似度: '.format(a, b), model.similarity(a, b))
#         except:
#             pass
#     similarity('天弘', '天弘基金')
#     similarity('飞月宝', '建信养老')
#     similarity('余额宝', '支付宝')
#     similarity('花呗', '借呗')
#
#     # most similar
#     words = ['摩拜', '花呗', '借呗', '余额宝', '理财', '还款', '天弘基金']
#     for word in words:
#         try:
#             print('nearest of {}, is {}\n'.format(word, model.most_similar(word, topn=5)))
#         except:
#             pass
#
#     def vec_most_similar(positive, negative, topn):
#         try:
#             print(positive, negative, topn)
#             print('\n'.join(
#                 [
#                     '{}: {}'.format(word, sim)
#                     for word, sim in
#                     model.most_similar(positive=positive,
#                                        negative=negative,
#                                        topn=topn)
#                 ]
#             ))
#         except:
#             pass
#     vec_most_similar(['买家', '收货'], ['卖家'], 5)
#     vec_most_similar(['花呗', '还款'], ['借呗'], 5)
#     vec_most_similar(['建信养老', '蚂蚁'], ['飞月宝'], 5)
#
#     def not_match(words):
#         try:
#             print(words, "不合群的词", model.doesnt_match(words.split()))
#         except:
#             pass
#     not_match('花呗 借呗 信用卡 卖家')
#     not_match('支付宝 余额宝 花呗 借呗 宝宝')

if __name__ == '__main__':
    w2v()
