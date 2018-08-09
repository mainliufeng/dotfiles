#!/usr/bin/env python
# -*- coding: utf-8 -*-


import os
import csv
import numpy as np
import fire
import pandas as pd
import tensorflow as tf
from tensorflow.contrib.tensorboard.plugins import projector


def word2vec_to_tensorboard(word2vec_path, output_path):
    df = pd.read_csv(word2vec_path, sep=' ', skiprows=[0], header=None,
                     quoting=csv.QUOTE_NONE)
    embeddings_vectors = df.loc[:,1:].values
    print('embedding shape:', embeddings_vectors.shape)

    # Create some variables.
    embedding_var = tf.Variable(embeddings_vectors, name='word_embeddings')

    config = projector.ProjectorConfig()
    embedding = config.embeddings.add()
    embedding.tensor_name = embedding_var.name
    embedding.metadata_path = 'metadata.tsv'
    summary_writer = tf.summary.FileWriter(output_path)
    projector.visualize_embeddings(summary_writer, config)

    init_op = tf.global_variables_initializer()
    saver = tf.train.Saver()
    with tf.Session() as sess:
        sess.run(init_op)
        save_path = saver.save(sess, os.path.join(output_path, "model.ckpt"))
        print("Model saved in path: %s" % save_path)

    df.loc[:,:0].to_csv(os.path.join(output_path, 'metadata.tsv'),
                        index=False, header=False, quoting=csv.QUOTE_NONNUMERIC)

if __name__ == '__main__':
    fire.Fire(word2vec_to_tensorboard)
